/*
 * API middleware functions for courses endpoints
 */

const router = require('express').Router();
const { validateAgainstSchema, extractValidFields } = require('../lib/validation');
const { requireAuthentication, generateAuthToken } = require('../lib/auth');
const { getUsers } = require('../models/users');
const { getCoursesPage,
        insertNewCourse,
        getCourseByCourseId,
        updateCourseById,
        deleteCourseByCourseId,
        getStudentListByCourseId,
        enrollStudent,
        unenrollStudent,
        getStudentRosterCSV,
        CourseSchema,
        CourseUpdateSchema
} = require('../models/courses');

const { enterErrorRequest } = require('../models/errors');

const { getInstructorByInstructorId } = require('../models/users');

const { getAssignmentByCourseId } = require('../models/assignments'); 

/*
 * Privlidge Level Declaration
 */

const admin = "admin";
const instructor = "instructor";
const student = "student";

// =========================================
// ===========  GET courses  ===============
// =========================================


/*
    Resource: GET /courses
    Action: Returns list of all courses. Paginated. Course response doesn't contain
            list of students in course or list of assignments for course.
    Permission Level: Authenticated User
    Media Type: JSON
*/
router.post('/', requireAuthentication, async (req, res, next) => {

    if(req.authenticated) {
        const searchParams = {
            page: req.query.page || null,
            subject: req.query.subject || null,
            number: req.query.number || null,
            term: req.query.term || null
        };

        try {
            const coursePage = await getCoursesPage(searchParams);
            
            coursePage.links = {};
            // Get HATEOUS paginated response
            if (coursePage.page < coursePage.totalPages) {
                coursePage.links.nextPage = `/courses?page=${coursePage.page + 1}`;
                coursePage.links.lastPage = `/courses?page=${coursePage.totalPages}`;
            } 
            if (coursePage.page > 1) {
                coursePage.links.prevPage = `/courses?page=${coursePage.page - 1}`;
                coursePage.links.firstPage = '/courses?page=1';
            }
           
            res.status(200).send(coursePage);
        } catch (err) {
            req.errorCode = 500;
            req.errorMessage = 'Error fetching course list.  Please try again later.';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();
    }
});

/*
    Resource: GET /courses/{id}
    Action: Returns summary data on a course, excluding list of students in course
            and list of assignments for the course
    Permission Level: Authenticated User
    Media Type: JSON
*/

router.get('/:id', requireAuthentication, async(req, res, next) => {
    
    if(req.authenticated){
        try{
            const courseId = req.params.id;
            const course = await getCourseByCourseId(courseId);

            res.status(200).send(course);
        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'Specified course id was not found';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();
    }
});

/*
    Resource: GET /courses/{id}/students
    Action: Return list containing student ids enrolled in course. 
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.get('/:id/students', requireAuthentication, async (req, res, next) => {
    if(req.role != student) {
        try {   
            
            const courseId = parseInt(req.params.id);
            await getCourseByCourseId(courseId);
            const students = await getStudentListByCourseId(courseId);
            
            res.status(200).send({
                students: students
            });
        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'Specified course does not exist';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();
    }
});

/*
    Resource: GET /courses/{id}/roster
    Action: Return CSV file containing info about all students who are enrolled in course. 
    Permission Level: Admin, Instructor
    Media Type: CSV File Download
*/

router.get('/:id/roster', requireAuthentication, async (req, res, next) => {
    if(req.authenticated && req.role != student) {
        try {
            const courseId = parseInt(req.params.id);
            const csvData = await getStudentRosterCSV(courseId);
            const filename = `student_class_${courseId}_roster.csv`;
         
            res.setHeader('Content-disposition', `attachment: ${filename}`);
            res.set('Content-Type', 'text/csv');
            res.status(200).send(csvData);

        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'Specified course does not exist';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();
    }
});

/*
    Resource: GET /courses/{id}/assignments
    Action: Returns list of assignment id for course 
    Permission Level: admin, instructor, student
    Media Type: JSON
*/

router.get('/:id/assignments', requireAuthentication, async (req, res, next) => {
    if(req.authenticated){
        try{
            const courseId = req.params.id;
            await getCourseByCourseId(courseId);
            const assignments = await getAssignmentByCourseId(courseId);
            res.status(200).send(assignments);
        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'Specified course does not exist';
            next();
        }
    }else{
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();
    }
});

// =========================================
// ===========  POST courses ===============
// =========================================

/*
    Resource: POST /courses
    Action: Creates new course 
    Permission Level: Admin
    Media Type: JSON
*/

router.post('/', requireAuthentication, async (req, res, next) => {
    // TODO: may want to change admin var or how this checks for admin 
    const body = extractValidFields(req.body, CourseSchema);
    if(validateAgainstSchema(body, CourseSchema)) {
        if(req.authenticated && req.role == admin){
            try {
                await getInstructorByInstructorId(body.instructorId);
                const id = await insertNewCourse(body);
                res.status(200).send({
                    id: id
                });
            } catch (err) {
                req.errorCode = 403;
                req.errorMessage = 'The request cannot be carried out by unauthenticated user';
                next();
            }
        }else {
            req.errorCode = 403;
            req.errorMessage = 'The request cannot be carried out by unauthenticated user';
            next();
        }   
    } else {
        req.errorCode = 400;
        req.errorMessage = 'The request body was either not present or did not contain any fields related to Course objects.';
        next();
    }
});

/*
    Resource: POST /courses/{id}/students
    Action: Enrolls or Unenrolls students from course. 
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.post('/:id/students', requireAuthentication, async (req, res, next) => {
    if(req.role != student && req.authenticated) {
        if(req.body.add || req.body.remove) {
            try{
                const courseId = parseInt(req.params.id);
                await getCourseByCourseId(courseId);
                let instructor = { id: req.body.id, action: true };
                if(!!req.body.add.length){
                    if(req.role == admin){
                        instructor = { id: req.body.id, action: false };
                    }
                    await enrollStudent(req.body.add, courseId, instructor);
                }
                if(!!req.body.remove.length){
                    if(req.role == admin){
                        instructor = { id: req.body.id, action: false };
                    }
                    await unenrollStudent(req.body.remove, courseId, instructor);
                }
                
                res.status(200).send({
                    success: "Succesfully changed student enrollment"
                });
            } catch (err) {
                req.errorCode = 404;
                req.errorMessage = 'Specified course was not found';
                next();
            }
        }else {
            req.errorCode = 400;
            req.errorMessage = 'The request body was either not present or did not contain any fields related to Course objects.';
            next();
        }
    }else {
        req.errorCode = 403;
        req.errorMessage = 'Unauthenticated user attempted to make this action';
        next();
    }
});

// =========================================
// ===========  PATCH courses ==============
// =========================================

/*
    Resource: PATCH /courses/{id}
    Action: Partial update on course. Enrolled students and assignments cannot be modified.
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.patch('/:id', requireAuthentication, async (req, res, next) => {
    
    if(validateAgainstSchema(req.body, CourseUpdateSchema)){
        if(req.authenticated && req.role != student) {
            const body = extractValidFields(req.body, CourseUpdateSchema);
            try {
                // TODO: Real added security would check if parameter is a number and not sql injection
                const courseId = parseInt(req.params.id);
                await updateCourseById(body.courseId, body);
                
                res.status(200).send({
                    success: "Successful update"
                });
            } catch (err) {
                req.errorCode = 404;
                req.errorMessage = 'Specified course Id not found';
                next();
            }
        } else {
            req.errorCode = 403;
            req.errorMessage = 'Unauthenticated user attempted to make this action';
            next();
        }
    } else {
        req.errorCode = 400;
        req.errorMessage = 'The request body was either not present or did not contain any fields related to Course objects.';
        next();
    }
});

// =========================================
// ===========  DELETE courses =============
// =========================================

/*
    Resource: DELETE /courses/{id}
    Action: Delete a course including enrolled students, assignments, any course ID relationship
    Permission Level: Admin
    Media Type: JSON
*/

router.delete('/:id', requireAuthentication, async (req, res, next) => {
    if(req.authenticated && req.role == admin) {
        try {
            const courseId = parseInt(req.params.id);
            const tryDelete = await deleteCourseByCourseId(courseId);
            console.log(" == delete : ", tryDelete);
            if(tryDelete){
                res.status(204).send({
                    success: "Successfully deleted course"
                });
            } else {
                next();
            }
        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'Specified course Id not found';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'Unauthenticated user attempted to make this action';
        next();
    }
});

module.exports = router;

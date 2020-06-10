/*
 * API middleware functions for assignment endpoints
 */

const router = require('express').Router();
const { validateAgainstSchema, extractValidFields } = require('../lib/validation');
const { requireAuthentication, generateAuthToken } = require('../lib/auth');
const {
    getAssignmentByCourseId,
    getAssignmentByAssignmentId,
    insertNewAssignment,
    updateAssignmentById,
    deleteAssignmnetByAssignmnetId,
    getAssignmentPage,
    AssignmentSchema
} = require('../models/assignments');

const {
    saveFile,
    SubmissionSchema
} = require('../models/submissions');

const admin = "admin";
const instructor = "instructor";
const student = "student";
// =========================================
// ===========  GET assignments  ===========
// =========================================

/*
    Resource: GET /assignments/{id}
    Action: Returns summary data of assignment, excluding list of submissions.
    Permission Level: User
    Media Type: JSON
*/
router.get('/:id', requireAuthentication, async (req, res, next) => {
    if(req.authenticated){
         const assignmentId = parseInt(req.params.id);
         try {
            const summary = await getAssignmentByAssignmentId(assignmentId);
            res.status(200).send(summary);
         } catch (err) {
           
        
            req.errorCode = 401;
            req.errorMessage = 'Specified Id was not found';
            next();    
         }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();    
    }
});


/*
    Resource: GET /assignments/{id}/submissions
    Action: Returns list of all submissions for an assignment. Paginated. Only 
            admin or instructor whose id matches inst id in course may have access
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.get('/:id/submissions', requireAuthentication, async (req, res, next) => {
    if(req.authenticated && req.role != student) {
        const courseId = req.params.id;
        const searchParams = {
            page: req.query.page || null,
            assignmentId: req.params.id || null,
            studentId: req.query.studentId || null,
        };

        try {
            const assignmentPage = await getAssignmentPage(searchParams, courseId);
            
            assignmentPage.links = {};
            // Get HATEOUS paginated response
            if (assignmentPage.page < assignmentPage.totalPages) {
                assignmentPage.links.nextPage = `/courses?page=${assignmentPage.page + 1}`;
                assignmentPage.links.lastPage = `/courses?page=${assignmentPage.totalPages}`;
            } 
            if (assignmentPage.page > 1) {
                assignmentPage.links.prevPage = `/courses?page=${assignmentPage.page - 1}`;
                assignmentPage.links.firstPage = '/courses?page=1';
            }
           
            res.status(200).send(assignmentPage);
        } catch (err) {
            req.errorCode = 500;
            req.errorMessage = 'Error fetching assignmnet list. Please try again later.';
            next();        
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();        
    }
});

// =========================================
// ===========  POST assignments ===========
// =========================================

/*
    Resource: POST /assignments
    Action: Create new assignment. Only admin or instructor can create assignment
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.post('/', requireAuthentication, async(req, res, next) =>{
   
    if(req.authenticated && req.role != student){
        const body = extractValidFields(req.body, AssignmentSchema);
        if(validateAgainstSchema(body, AssignmentSchema)){
            try{
                const id = await insertNewAssignment(body);
                res.status(201).send({
                    id: id 
                });
            } catch (err) {
                req.errorCode = 500;
                req.errorMessage = 'Error fetching course list.  Please try again later.';
                next();    
            }
        } else {
            req.errorCode = 400;
            req.errorMessage = 'The request body was either not present or did not contain any fields related to Course objects.';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();    
    }
});

/*
    Resource: POST /assignments/{id}/submissions
    Action: Create new assignment submission. This is the endpoint students submit
            their assignments
    Permission Level: Student
    Media Type: JSON
*/

router.post('/:id/submissions', requireAuthentication, async(req, res, next) => {
    if(req.body.file && req.body.id){
        const filePath = req.body.file;

        if(req.authenticated && req.role == student){
            try{
                const body = {
                    assignmentId: req.params.id,
                    studentId: req.body.id,
                    file: filePath
                };

                const _id = await saveFile(body);
                res.status(200).send({
                    id: _id
                });
            } catch (err) {
                req.errorCode = 500;
                req.errorMessage = 'Error processing file please re-upload';
                next();    
            }
        } else {
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


// =========================================
// ===========  PATCH assignments ==========
// =========================================

/*
    Resource: PATCH /assignments/{id}
    Action: Partial updates to assignment. Only admin or instructor can modify. 
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.patch('/:id', requireAuthentication, async(req, res, next) => {
    if(req.authenticated && req.role != student){
        const body = extractValidFields(req.body, AssignmentSchema);
        if(validateAgainstSchema(body, AssignmentSchema)){
            const assignmentId = parseInt(req.params.id);
            try{
                await updateAssignmentById(body, assignmentId);
                res.status(200).send({
                    success: "Success updating assignment"
                });
            } catch (err){
                req.errorCode = 401;
                req.errorMessage = 'Specified Id was not found';
                next();    
            }    
        } else {
            req.errorCode = 400;
            req.errorMessage = 'The request body was either not present or did not contain any fields related to Course objects.';
            next();    
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();    
    }
});

// =========================================
// ===========  DELETE assignments =========
// =========================================

/*
    Resource: DELETE /assignments/{id}
    Action: Completely remove data for a assignment, including all submissions. 
    Permission Level: Admin, Instructor
    Media Type: JSON
*/

router.delete('/:id', requireAuthentication, async(req, res, next) => {
    if(req.authenticated && req.role != student){
        const body = extractValidFields(req.body, SubmissionSchema);
        try{
            const assignmentId = parseInt(req.params.id);
            await deleteAssignmnetByAssignmnetId(assignmentId);
            res.status(204).send({
                success: "Successfuly deleted assignment"
            });
        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'Specified Id was not found';
            next();    
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();    
    }
});

module.exports = router;

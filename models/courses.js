/*
 * Course schema and data accessor methods;
 */
const Json2csvParser = require('json2csv').Parser;
const mysqlPool = require('../lib/mysqlPool');
const { extractValidFields, validateAgainstSchema } = require('../lib/validation');
const { paginationQuery, paginationArray } = require('../lib/queryBuilder');


/*
 * Schema describing required/optional fields of a courses object.
 */

const CourseSchema = {
    number: { required: true },
    subject: { required: true },
    title: { required: true },
    term: { required: true },
    instructorId: { required: true }
};
exports.CourseSchema = CourseSchema;

const CourseUpdateSchema = {
    courseId: { required: true },
    number: { required: true },
    subject: { required: true },
    title: { required: true },
    term: { required: true },
    instructorId: { required: true }
};
exports.CourseUpdateSchema = CourseUpdateSchema;

const CoursePaginationSchema = {
    number: { required: false },
    subject: { required: false },
    term: { required: false }
}

/*
 * Privlidge Level Declaration
 */

const admin = "admin";
const instructor = "instructor";
const student = "student";

/*
    Query: Creates a new course 
    Returns: Course Insert ID 
    Return Value: int
 */

async function insertNewCourse(body) {

    const [ results ] = await mysqlPool.query(
        'INSERT INTO courses SET ?',
        body 
    );
    // Update instructors table 
    await mysqlPool.query(
        'INSERT INTO instructors VALUES (?,?)',
        [ results.insertId, body.instructorId ]
    );

    return results.insertId;
}
exports.insertNewCourse = insertNewCourse;

/*
    Query: Get a list of what classes a student is enrolled in
    Returns: List of classes
    Return Value: JSON Object
 */

async function getCourseListByUser(userId, role) {
    
    let query = '';
    if(role == instructor) {
        query = 'SELECT courses.subject, courses.number, courses.title, courses.term, instructors.instructorId FROM courses INNER JOIN instructors ON instructors.instructorId=? AND instructors.courseId=courses.courseId';
    } else if(role == student) {
        query = 'SELECT courses.subject, courses.number, courses.title, courses.term, courses.instructorId FROM courses INNER JOIN enrolledStudents ON enrolledStudents.studentId=? AND enrolledStudents.courseId=courses.courseId';
    } else { // admin
        throw new Error("Admin hasn't been programmed to select a user list");
    }

    const [ results ] = await mysqlPool.query(
        query,
        [userId]
    );

    return results;
}
exports.getCourseListByUser = getCourseListByUser;

/*
    Query: Gets a list of all students in a course
    Returns: List of students
    Return Value: JSON Object
 */

async function getStudentListByCourseId(courseId) {
    const [ results ] = await mysqlPool.query(
        'SELECT studentId FROM enrolledStudents WHERE courseId=?',
        [courseId]
    );

    return results;
}
exports.getStudentListByCourseId = getStudentListByCourseId;

/*
    Query: Get a course based on query parameters
    Returns: Paginated response
    Return Value: JSON Object
 */

async function getCoursesPage(searchParams) {
    
    const count = await countCourses();
    const pageSize = 5;
    const lastPage = Math.ceil(count / pageSize);
    searchParams.page = searchParams.page > lastPage ? lastPage : searchParams.page;
    searchParams.page = searchParams.page < 1 ? 1 : searchParams.page;
    const offset = (searchParams.page - 1) * pageSize;
    
    searchParams = extractValidFields(searchParams, CoursePaginationSchema);
   
    let queryConditionals = paginationQuery(searchParams, CoursePaginationSchema);
    let query = 'SELECT * FROM courses ORDER BY courseId LIMIT ?,?';
    let arr = [];
    // Check truthy values!!
    if(!!searchParams.subject || !!searchParams.term || !!searchParams.number){
        arr = paginationArray(searchParams, CoursePaginationSchema);
        query = 'SELECT * FROM courses WHERE ' + queryConditionals + ' ORDER BY courseId LIMIT ? , ?';
    }
    arr.push(offset);
    arr.push(pageSize);
   
    const [ results ] = await mysqlPool.query(
        query,
        arr
    );
    
    return {
        courses: results,
        page: searchParams.page,
        totalPages: lastPage,
        pageSize: pageSize,
        count: count 
    };
}
exports.getCoursesPage = getCoursesPage;

/*
    Query: Grab course information from its ID
    Returns: Course Information
    Return Value: JSON Object
 */

async function getCourseByCourseId(id){
    const [ results ] = await mysqlPool.query(
        'SELECT subject, number, title, term, instructorId FROM courses WHERE courseId=?',
        [id]
    );
    
    if(results.length == 0){
        throw new Error("getCourseByCourseId: No course by id");
    }
    
    return results;
}
exports.getCourseByCourseId = getCourseByCourseId;

/*
    Query: Counts the number of courses in course table
    Returns: Total number of courses
    Return Value: int
 */

async function countCourses() {
    const [ results ] = await mysqlPool.query(
        'SELECT COUNT(*) AS courseId FROM users'
    );

    return results[0];
}

/*
    Query: Update a course by its ID
    Returns: If any row was updated
    Return Value: JSON Object
 */

async function updateCourseById(id, updateValues){

    const [ results ] = await mysqlPool.query(
        'UPDATE courses SET ? WHERE courseId=?',
        [updateValues, id]
    );
    
    if(results.affectedRows == 0){
        throw new Error("No course by course ID");
    }

    return results;
}
exports.updateCourseById = updateCourseById;

/*
    Query: Deletes a course by its ID
    Returns: The results of rows affected by transaction
    Return Value: JSON Object
 */

async function deleteCourseByCourseId(courseId) {
    const [ results ] = await mysqlPool.query(
        'DELETE FROM courses WHERE courseId=?',
        [courseId]
    );

    if(results.affectedRows == 0){
        throw new Error("No course by course ID");
    }

    return results;
}
exports.deleteCourseByCourseId = deleteCourseByCourseId;

/*
    Query: Adds a student to the enrolledStudents table
    Returns: The transaction history of the query operation
    Return Value: JSON Object
 */

async function enrollStudent(studentList, courseId, instructor){
    let results = [];
    let noInserts = true;
    for (var student in studentList){
        let queryVars = {
            courseId: courseId,
            studentId: studentList[student]
        }
        let makeInsert = true;
        // Check if instructor is making enrollment
        if(instructor.action){
            results = await mysqlPool.query(
                'SELECT instructorId FROM courses WHERE courseId=? AND instructorId=?',
                [courseId, instructor.id]
            );
            if(results[0].length == 0){
                makeInsert = false;
            } else {
                noInserts = false;
            }
        } 
        if(makeInsert){
            results = await mysqlPool.query(
                'INSERT INTO enrolledStudents SET ?',
                queryVars
            );
        }
    }

    if(noInserts){
        throw new Error("enrollStudent: No student was enrolled with action given parameters");
    }

    return results;
}
exports.enrollStudent = enrollStudent;

/*
    Query: Unenroll a student or remove them from the enrollStudent list
    Returns: The transaction history of the query operation
    Return Value: JSON Object
 */

async function unenrollStudent(studentList, courseId, instructor){
    let results = [];
    let noDeletes = true;
    for (var student in studentList){
        let makeDelete = true;
        // Check if instructor is making enrollment
        if(instructor.action){
            results = await mysqlPool.query(
                'SELECT instructorId FROM courses WHERE courseId=? AND instructorId=?',
                [courseId, instructor.id]
            );
            if(results[0].length == 0){
                makeDelete = false;
            } else {
                noDeletes = false;
            }
        } 
        if(makeDelete){
            results = await mysqlPool.query(
                'DELETE FROM enrolledStudents WHERE studentId=? AND courseId=?',
                [studentList[student], courseId]
            );
        }
    }

    if(noDeletes){
        throw new Error("unenrollStudent: No student was unenrolled with action given parameters");
    }

    return results;
}
exports.unenrollStudent = unenrollStudent;

/*
    Query: Gets the student roster, creates a CSV file
    Returns: File of students enrolled in a class
    Return Value: CSV File
 */

async function getStudentRosterCSV(courseId) {
    const [ results ] = await mysqlPool.query(
        'SELECT enrolledStudents.studentId, users.name, users.email FROM users INNER JOIN enrolledStudents ON enrolledStudents.courseId=? AND enrolledStudents.studentId = users.userId',
        [courseId]
    );
    if(results.length == 0) {
        throw new Error("getStudentRosterCSV: no students were enrolled to class or class doesnt exist");
    }
    const jsonResults = JSON.parse(JSON.stringify(results));
    const csvFields = ['studentId', 'name', 'email'];
    const json2csvParser = new Json2csvParser({csvFields});
    const csvData = json2csvParser.parse(jsonResults);
  
    return csvData;
}
exports.getStudentRosterCSV = getStudentRosterCSV;
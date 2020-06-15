/*
 * Assignment schema and data accessor methods;
 */

const mysqlPool = require('../lib/mysqlPool');
const { extractValidFields } = require('../lib/validation');
const { paginationArray, paginationQuery } = require('../lib/queryBuilder');
const { countSubmissionsByAssignmentId } = require('./submissions');

/*
 * Schema describing required/optional fields of a assignments object.
 */

const AssignmentSchema = {
    courseId: { required: true },
    title: { required: true },
    points: { required: true },
    due: { required: true }
};
exports.AssignmentSchema = AssignmentSchema;

const AssignmentPaginationSchema = {
    assignmentId: { required: false },
    studentId: { required: false }
};
exports.AssignmentPaginationSchema = AssignmentPaginationSchema;

/*
 * Privlidge Level Declaration
 */

const admin = "admin";
const instructor = "instructor";
const student = "student";

/*
    Query: Gets an assignment by a courses ID
    Returns: List of assignments in a course
    Return Value: JSON Object
 */

 async function getAssignmentByCourseId(courseId) {
    const [ results ] = await mysqlPool.query(
        'SELECT assignmentId FROM assignments WHERE courseId=?',
        [courseId]
    );

    return { assignmnets: results };
 }
 exports.getAssignmentByCourseId = getAssignmentByCourseId;

/*
    Query: Get assignment information based on its ID
    Returns: Information on an assignment
    Return Value: JSON Object
 */

 async function getAssignmentByAssignmentId(assignmentId) {
    const [ results ] = await mysqlPool.query(
        'SELECT courseId, title, points, due FROM assignments WHERE assignmentId=?',
        [assignmentId]
    );

    if(results.length == 0){
        throw new Error("assignment id does not exist");
    }

    return results;
 }
 exports.getAssignmentByAssignmentId = getAssignmentByAssignmentId;

 /*
    Query: Get an assignment page 
    Returns: Paginated response 
    Return Value: JSON Object
 */

 async function getAssignmentPage(searchParams) {
    
    const count = await countSubmissionsByAssignmentId(searchParams.assignmentId);
    const pageSize = 5;
    const lastPage = Math.ceil(count / pageSize);
    searchParams.page = searchParams.page > lastPage ? lastPage : searchParams.page;
    searchParams.page = searchParams.page < 1 ? 1 : searchParams.page;
    const offset = (searchParams.page - 1) * pageSize;
    
    searchParams = extractValidFields(searchParams, AssignmentPaginationSchema);
   
    let queryConditionals = paginationQuery(searchParams, AssignmentPaginationSchema);
    let query = 'SELECT * FROM submissions ORDER BY assignmentId LIMIT ?,?';
    let arr = [];
    // Check truthy values!!
    if(!!searchParams.studentId){
        arr = paginationArray(searchParams, AssignmentPaginationSchema);
        query = 'SELECT * FROM submissions WHERE ' + queryConditionals + ' ORDER BY assignmentId LIMIT ? , ?';
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
exports.getAssignmentPage = getAssignmentPage;

/*
    Query: Counts the number of assignments by a course ID 
    Returns: Number of assignments in a class
    Return Value: int
 */

async function countAssignmentsByCourseId(courseId) {
    const [ results ] = await mysqlPool.query(
        'SELECT COUNT(*) AS courseId FROM assignments WHERE courseId=?',
        [courseId]
    );

    return results[0];
}

/*
    Query: Inserts a new assignment
    Returns: The insert ID of the newly added assignment
    Return Value: int
 */

 async function insertNewAssignment(body) {
     const [ results ] = await mysqlPool.query(
         'INSERT INTO assignments SET ?',
         body 
     );

     return results.insertId;
 }
 exports.insertNewAssignment = insertNewAssignment;
 
/*
    Query: Updates the information on a assignment
    Returns: The result of transaction
    Return Value: JSON Object
 */

async function updateAssignmentById(body, assignmentId) {

    const [ results ] = await mysqlPool.query(
        'UPDATE assignments SET ? WHERE assignmentId=? AND courseId=?',
        [body, assignmentId, body.courseId]
    );
   
    if(results.affectedRows == 0){
        throw new Error("No asig by id");
    }

    return results;
}
exports.updateAssignmentById = updateAssignmentById;

/*
    Query: Deletes a assignment by its ID
    Returns: The result of transaction
    Return Value: JSON Object
 */

async function deleteAssignmnetByAssignmnetId(assignmentId) {
    const [ results ] = await mysqlPool.query(
        'DELETE FROM assignments WHERE assignmentId=?',
        [assignmentId]
    );

    if(results.affectedRows == 0){
        throw new Error("No asig by id");
    }

    return results;
}
exports.deleteAssignmnetByAssignmnetId = deleteAssignmnetByAssignmnetId;
/*
 * Submission schema and data accessor methods;
 */

const mysqlPool = require('../lib/mysqlPool');
const { extractValidFields } = require('../lib/validation');

/*
 * Schema describing required/optional fields of a submission object.
 */

const SubmissionSchema = {
    studentId: { required: true },
    assignmentId: { required: true },
    file: { required: true }
};
exports.SubmissionSchema = SubmissionSchema;

/*
    Query: Gets the total number of submissions for a specific assignment
    Returns: Total number of submissions
    Return Value: int
 */

async function countSubmissionsByAssignmentId(assignmentId) {
    const [ results ] = await mysqlPool.query(
        'SELECT COUNT(*) AS assignmentId FROM submissions WHERE assignmentId=?',
        [assignmentId]
    );

    return results[0];
}
exports.countSubmissionsByAssignmentId = countSubmissionsByAssignmentId;

/*
    Query: Inserts a file into submissions table
    Returns: insertId
    Return Value: int
 */

async function saveFile(body) {

    const [ results ] = await mysqlPool.query(
        'INSERT INTO submissions SET ?',
        body 
    );

    return results.insertId;
}
exports.saveFile = saveFile;
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

async function countSubmissionsByAssignmentId(assignmentId) {
    const [ results ] = await mysqlPool.query(
        'SELECT COUNT(*) AS assignmentId FROM submissions WHERE assignmentId=?',
        [assignmentId]
    );

    return results[0];
}
exports.countSubmissionsByAssignmentId = countSubmissionsByAssignmentId;

async function saveFile(body) {

    const [ results ] = await mysqlPool.query(
        'INSERT INTO submissions SET ?',
        body 
    );

    return results.insertId;
}
exports.saveFile = saveFile;
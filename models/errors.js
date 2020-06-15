/*
 * Error data accessor methods;
 */

const mysqlPool = require('../lib/mysqlPool');
const { extractValidFields } = require('../lib/validation');


/*
    Query: Creates and inserts an error to look at error request history
    Returns: insertId from the error codes query
    Return Value: int
 */

 async function enterErrorRequest(errorCode, err) {
     
    const [ results ] = await mysqlPool.query(
        'INSERT INTO errors (errorCode, errorResponse) VALUES (?,?)',
        [errorCode, err]
    );
   
    return results.insertId;
 }
 exports.enterErrorRequest = enterErrorRequest;
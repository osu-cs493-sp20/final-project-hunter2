/*
 * Error schema and data accessor methods;
 */

const mysqlPool = require('../lib/mysqlPool');
const { extractValidFields } = require('../lib/validation');

/*
 * Schema describing required/optional fields of a error object.
 */

 async function enterErrorRequest(errorCode, err) {
     
    const [ results ] = await mysqlPool.query(
        'INSERT INTO errors (errorCode, errorResponse) VALUES (?,?)',
        [errorCode, err]
    );
   
    return results.insertId;
 }
 exports.enterErrorRequest = enterErrorRequest;
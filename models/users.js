/*
 * User schema and data accessor methods;
 */

const mysqlPool = require('../lib/mysqlPool');
const bcrypt = require('bcryptjs');

const { extractValidFields } = require('../lib/validation');

/*
 * Schemas describing required fields of a users object.
 */

const UserSchema = {
    name: { required: true },
    email: { required: true },
    password: { required: true },
    role: { required: true }
};
exports.UserSchema = UserSchema;

const UserLoginSchema = {
    email: { required: true },
    password: { required: true }
};
exports.UserLoginSchema = UserLoginSchema;

/*
 * Privlidge Level Declaration
 */

const admin = "admin";
const instructor = "instructor";
const student = "student";

/*
    Query: Creates and inserts a new user
    Returns: users table userId for new user
    Return Value: int
 */

async function insertNewUser(user, authenticated, CPL) {
    
    if(user.role == instructor || user.role == admin){
        // Only authenticated users with admin role may create other 
        if(!authenticated && CPL != admin){
            // Error client with CP level is not authorized
            throw new Error("client does not have privlidge for transaction");
        }
    }
    // Encrypt users password before DB store
    user.password = await bcrypt.hash(
        user.password,
        10
    );

    const [ results ] = await mysqlPool.query(
        "INSERT INTO users SET ?",
        user
    );
    return results.insertId;
}
exports.insertNewUser = insertNewUser;

/*
    Query: Checks if email is present in users table. Checks if encrypted password matches
    Returns: userId and true or false if user is verified.
    Return Value: JSON Object
 */

async function validateUser(email, password){
    const user = await getUserByEmail(email);
    const verifiedUser = await bcrypt.compare(password, user.password);
    return {
        userId: user.userId,
        verified: verifiedUser
    };
}
exports.validateUser = validateUser;

/*
    Query: Gets user information from users table by user email
    Returns: User information
    Return Value: JSON Object
 */

async function getUserByEmail(email){
    const [ results ] = await mysqlPool.query(
        'SELECT * FROM users WHERE email=?',
        [email]
    );

    return results[0];
}

/*
    Query: Gets user information from users table by user id
    Returns: User information
    Return Value: JSON Object
 */

async function getUserById(userId) {
    const [ results ] = await mysqlPool.query(
        'SELECT * FROM users WHERE userId=?',
        [userId]
    );

    return results[0];
}
exports.getUserById = getUserById;

/*
    Query: Gets all users information
    Returns: User information
    Return Value: JSON Object
 */

async function getUsers() {
    const [ results ] = await mysqlPool.query(
        'SELECT * FROM users'
    );

    return results;
}
exports.getUsers = getUsers;

async function getInstructorByInstructorId(instructorId){
    const [ results ] = await mysqlPool.query(
        'SELECT instructorId FROM instructors WHERE instructorId=?',
        [instructorId]
    );

    if(results.length == 0) {
        throw new Error("getInstructorByInstructorId: No instructor by id");
    }

    return results;
}
exports.getInstructorByInstructorId = getInstructorByInstructorId;
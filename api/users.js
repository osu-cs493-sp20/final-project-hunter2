/*
 * API middleware functions for users endpoints
 */

const router = require('express').Router();
const { validateAgainstSchema, extractValidFields } = require('../lib/validation');
const { requireAuthentication, generateAuthToken } = require('../lib/auth');
const { UserSchema,
        UserLoginSchema,
        insertNewUser,
        getUserById,
        validateUser
} = require('../models/users');

const { getCourseListByUser } = require('../models/courses');
// =========================================
// ===========  GET users  ===============
// =========================================


/*
    Resource: GET /users/{id}
    Action: Returns information on user. Student ID's may access list of course ID's their enrolled in.
            Instructor ID's may access courses they teach. 
    Permission Level: Authenticated User
    Media Type: JSON
*/

router.get('/:id', requireAuthentication, async (req, res, next) => {
    const userId = parseInt(req.params.id);
    console.log("user id: ", userId);
    if(req.authenticated && req.body.id == userId){
        try {
            const user = await getUserById(userId);
            const courseList = await getCourseListByUser(user.userId, user.role);
            
            // Responds with courses either students are enrolled in or courses a teacher teaches
            res.status(200).send(courseList);

        } catch (err) {
            req.errorCode = 404;
            req.errorMessage = 'No courses found associated with the user';
            next();
        }
    } else {
        req.errorCode = 403;
        req.errorMessage = 'The request cannot be carried out by unauthenticated user';
        next();
    }
    
});

// =========================================
// ===========  POST users =================
// =========================================

/*
    Resource: POST /users
    Action: Create a user. Only admin can create admin or instructor roles.
    Permission Level: Any User -> Student, Admin -> Admin, Instructor
    Media Type: JSON
*/

router.post('/', requireAuthentication, async (req, res, next) => {

    // Grab specified fields. If user is authenticated, a CP level of student or higher.
    // Otherwise they are given student CP level which may only create a student account.
    const body = extractValidFields(req.body, UserSchema);
    const clientPrivlidgeLevel = req.role == null ? req.role : "student";

    if(validateAgainstSchema(body, UserSchema)){
        try{
            const id = await insertNewUser(body, req.authenticated, clientPrivlidgeLevel);
            res.status(201).send({
                id: id
            });
        } catch (err) {
            req.errorCode = 403;
            req.errorMessage = 'User was not authenticated to make authorized request';
            next();
        }
    }else{
        req.errorCode = 400;
        req.errorMessage = 'The request body was either not present or did not contain valid fields';
        next();
    }
});

/*
    Resource: POST /users/login
    Action: Authenticate user and login with email and password.
    Permission Level: User
    Media Type: JSON, JWT Token
*/

router.post('/login', async (req, res, next) => {

    const body = extractValidFields(req.body, UserLoginSchema);
    if(validateAgainstSchema(body, UserLoginSchema)){
        try{
            const authentication = await validateUser(
                body.email,
                body.password
            );

            if(authentication.verified) {
                const token = generateAuthToken(authentication.userId);

                res.status(200).send({
                    token: token
                });
            } else {
                req.errorCode = 401;
                req.errorMessage = 'User password or email is invalid';
                next();
            }
        } catch (err) {
            req.errorCode = 500;
            req.errorMessage = 'Internal server error occurred';
            next();
        }
    }else{
        req.errorCode = 400;
        req.errorMessage = 'The request body was either not present or did not contain valid fields';
        next();
    }
});
module.exports = router;
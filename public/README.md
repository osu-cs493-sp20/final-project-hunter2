# Unit Testing
This file outlines all of the tests conducted in the curl-bash script. These tests 
are developed to test each endpoint in the server api. They are organized by each endpoint
access point (/users, /courses, /assignments). Displaying successful and unsuccessful query 
results. The result of a test run will be included in output.txt. 

## USER TESTS
### 1. User Creation POST /users
    Successful Queries: 
        -> Any user may create a student account
        -> Only authenticated users with admin privlidge can create inst or admin 
    Failed Queries:
        -> Unauthenticated user tries to make admin or inst 
        -> Request body is not filled correctly

### 2. User Login POST /users/login
    Successful Queries:
        -> User provides authentic credentials, receives token 
    Failed Queries:
        -> User doesn't provide authentic credentials
        -> Request body is not filled correctly 

### 3. GET user information GET /users{id}
    Successful Queries:
        -> Body id matches params id, and user is authentic 
    Failed Queries:
        -> User is unauthenticated
        -> Authenticated user is trying to access another users data 
    Note: body "id":"4"

## COURSE TESTS
### 1. Fetch all courses GET /courses
    Successful Queries:
        -> If filters are set to find a page and user is authenticated  
    Failed Queries:
        -> User is not authenticated

### 2. Create a course POST /courses 
    Successful Queries:
        -> User is admin, body is correct, and there is instructor by id 
    Failed Queries:
        -> A Non admin attempts to create a class 
        -> Request body is not filled correctly
        -> InstrutorId field doesn't identify a instructor id in DB 
    
### 3. Provides summary of course GET courses/{id}
    Successful Queries:
        -> User is authentic and parameter {id} matches a courseID
    Failed Queries:
        -> User is not authenticated 
        -> {id} is not found in courses DB 

### 4. Update a course PATCH courses/{id}
    Successful Queries:
        -> User is authentic and parameter {id} matches a courseID and body is correct 
    Failed Queries:
        -> Body doesn't have full fields
        -> User is not authenticated 
        -> No {id} is found in courses DB 

### 5. DELETES a course DELETE courses/{id}
    Successful Queries:
        -> User is authentic and parameter {id} matches a courseID
    Failed Queries:
        -> No {id} is found in courses DB 
        -> Unauthorized user attempts to remove course (non admin) 

### 6. GET list of students enrolled in course GET courses/{id}/students
    Successful Queries:
        -> User is authentic and parameter {id} matches a courseID
    Failed Queries: 
        -> Unauthorized user attempts to remove course (non admin or instructor) 
        -> No {id} is found in courses DB 

### 7. Update enrollment for students POST /courses/{id}/students
    Successful Queries:
        -> Admin can make a request 
        -> Instructor can only enroll/unenroll students from their class 
    Failed Queries:
        -> Instructor attempts to add/remove students from not their class 
        -> Unauthenticated user 

### 8. Fetch CSV containing list of student enrollment GET /courses/{id}/roster
    Successful Queries:
        -> Course is a valid course {id} and user is authenticated
    Failed Queries:
        -> Course can't identify course by {id}
        -> user is not authenticated

### 9. Return list containing asignment ids GET /courses/{id}/assignments
    Successful Queries: 
        -> Course ID exists and authenticated user 
    Failed Queries:
        -> Not authenticated user 
        -> No {id} is found in courses DB 

## ASSIGNMENTS TESTS
### 1. Create new assignment POST /assignments
    Successful Queries:
        -> Assignment body is correct and user is authenticated
    Failed Queries:
        -> User is not authenticated
        -> Body is missing elements

### 2. Returns summary data on assignment GET /assignments/{id}
    Successful Queries:
        -> {id} exists in assignment table and user is authenticated
    Failed Queries:
        -> No {id} is found in assignment DB
        -> User is not authenticated (proprietary data!!)

### 3. Partial update on data for assignment PATCH /assignments/{id}
    Successful Queries:
        -> {id} exists for assignment and assignmentId matches altered assignment 
    Failed Queries:
        -> Body is missing elements
        -> User is not authenticated 

### 4. Delete a assignment, all its submissions DELETE /assignments/{id}
    Successful Queries:
        -> {id} exists for assignment and assignmentId matches altered assignment 
    Failed Queries:
        -> Unauthorized user tries to delete
        -> No {id} is found in assignment DB

### 5. Return list of all submissions for assignment. paginated GET /assignments/{id}/submissions
    Successful Queries:
        -> If filters are set to find a page and user is authenticated
    Failed Queries:
        -> If user is not authenticated

### 6. Create new submission for assignment(student entrypoint) POST /assignments/{id}/submissions
    Successful Queries:
        -> filepath is included in body. Id of student is included in body and there exists a assignment
    Failed Queries:
        -> No assignment found by {id}
        -> Unauthorized user is attempting to access data 
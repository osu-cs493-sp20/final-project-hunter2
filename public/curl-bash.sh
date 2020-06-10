#!.bin/bash
######################################################
######################################################
########    Author: Blake Hudson
########    File: Provides test queries for REST API
######################################################
######################################################

echo "============================================================================================================================================"
echo "==========================================================USER TESTS========================================================================"
echo "============================================================================================================================================"
echo "  "
echo "  "
echo "1. User Creation POST /users"
echo "Successful Queries:"
test_1_1_1=$(curl -X POST "http://localhost:8000/users" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"name\":\"Jane Doe\",\"email\":\"doej@oregonstate.edu\",\"password\":\"hunter2\",\"role\":\"student\"}")
echo "Inserting student: $test_1_1"
fakeBearerToken="111.222.333"
bearerToken=$(curl -X POST "http://localhost:8000/users/login" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"email\":\"tigerface@boxing.com\",\"password\":\"hunter2\"}" | jq -r '.token')
test_1_1_2=$(curl -X POST "http://localhost:8000/users" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"name\":\"Bob Ross\",\"email\":\"wolf@wallstreet.edu\",\"password\":\"hunter2\",\"role\":\"admin\"}")
echo "  ->Inserting admin: $test_1_1_2"
echo "  "
echo "Failed Queries:"
test_1_1_3=$(curl -X POST "http://localhost:8000/users" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"email\":\"wolf@wallstreet.edu\",\"password\":\"hunter2\",\"role\":\"admin\"}")
echo "  ->Non admin attempts to make admin: $test_1_1_3"
test_1_1_4=$(curl -X POST "http://localhost:8000/users" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"2\",\"email\":\"wolf@wallstreet.edu\",\"password\":\"hunter2\",\"role\":\"admin\"}")
echo "  ->Request body not filled: $test_1_1_4"
echo " "
echo " "
echo "2. User Login POST /users/login"
echo "Successful Queries:"
test_1_2_1=$(curl -X POST "http://localhost:8000/users/login" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"email\":\"billburr@comedy.com\",\"password\":\"hunter2\"}")
echo "  ->Bearer Token for login: $test_1_2_1"
echo " "
echo "Failed Queries:"
test_1_2_2=$(curl -X POST "http://localhost:8000/users/login" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"email\":\"billburr@comedy.com\",\"password\":\"hunterssss2\"}")
echo "  ->Unauthentic user: $test_1_2_2"
test_1_2_3=$(curl -X POST "http://localhost:8000/users/login" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"password\":\"hunter2\"}")
echo "  ->Request body not filled: $test_1_2_3"
echo " "
echo " "
echo "3. GET user information GET /users"
echo "Successful Queries:"
test_1_3_1=$(curl --location --request GET 'http://localhost:8000/users/2' \
-H "Authorization: Bearer ${bearerToken}" \
-H "Content-Type: application/json" \
-d "{\"id\":\"2\"}")
echo "  ->User information: $test_1_3_1"
echo " "
echo "Failed Queries:"
test_1_3_2=$(curl --location --request GET 'http://localhost:8000/users/2' \
-H "Content-Type: application/json" \
-d "{\"id\":\"2\"}")
echo "  ->Unauthentic user: $test_1_3_2"
test_1_3_3=$(curl --location --request GET 'http://localhost:8000/users/2' \
-H "Authorization: Bearer ${bearerToken}" \
-H "Content-Type: application/json" \
-d "{\"id\":\"5\"}")
echo "  ->Attempting to access other users data: $test_1_3_3"
echo " "
echo " "
echo "============================================================================================================================================"
echo "=======================================================COURSE TESTS========================================================================="
echo "============================================================================================================================================"
echo "1. Fetch all courses GET /courses"
echoo "Successful Queries:"
test_2_1_1=$(curl -X GET "http://localhost:8000/courses?page=1&subject=CS&number=493&term=sp20" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Filtered Response: $test_2_1_1"
test_2_1_2=$(curl -X GET "http://localhost:8000/courses?page=1" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Less filtered Response: $test_2_1_2"
echo " "
echo "Failed Queries:"
test_2_1_3=$(curl -X GET "http://localhost:8000/courses?page=1" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"300\"}")
echo "  ->User is not authentic: $test_2_1_3"
echo " "
echo " "
echo "2. Create a course POST /courses "
echo "Successful Queries:"
test_2_2_1=$(curl -X POST "http://localhost:8000/courses" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"subject\":\"CS\",\"number\":500,\"title\":\"Parallel Programming\",\"term\":\"sp19\",\"instructorId\":\"2\"}")
echo "  ->Inserting course: $test_2_2_1"
echo " "
echo "Failed Queries:"
test_2_2_2=$(curl -X POST "http://localhost:8000/courses" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"5\",\"subject\":\"CS\",\"number\":500,\"title\":\"Parallel Programming\",\"term\":\"sp19\",\"instructorId\":\"2\"}")
echo "  ->Unauthenticated user: $test_2_2_2"
test_2_2_3=$(curl -X POST "http://localhost:8000/courses" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"5\",\"number\":500,\"title\":\"Parallel Programming\",\"term\":\"sp19\",\"instructorId\":\"2\"}")
echo "  ->Req body incomplete: $test_2_2_3"
test_2_2_4=$(curl -X POST "http://localhost:8000/courses" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"3\",\"subject\":\"CS\",\"number\":500,\"title\":\"Parallel Programming\",\"term\":\"sp19\",\"instructorId\":\"2\"}")
echo "  ->Instructor id doesn't match class they are making: $test_2_2_4"
echo " "
echo " "
echo "3. Provides summary of course GET courses/{id}"
echo "Successful Queries:"
test_2_3_1=$(curl -X GET "http://localhost:8000/courses/3" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Course 3 summary: $test_2_3_1"
echo " "
echo "Failed Queries:"
test_2_3_2=$(curl -X GET "http://localhost:8000/courses/3" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"200\"}")
echo "  ->Unauthentic user: $test_2_3_2"
test_2_3_3=$(curl -X GET "http://localhost:8000/courses/300" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"2\"}")
echo "  ->Course not found: $test_2_3_3"
echo " "
echo " "
echo "4. Update a course PATCH courses/{id}"
echo "Successful Queries:"
test_2_4_1=$(curl -X PATCH "http://localhost:8000/courses/3" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"3\",\"courseId\":\"15\",\"subject\":\"mth\",\"number\":\"432\",\"title\":\"something new\",\"instructorId\":\"3\"}")
echo "  ->Update Class: $test_2_4_1"
echo " "
echo "Failed Queries:"
test_2_4_2=$(curl -X PATCH "http://localhost:8000/courses/3" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"3\",\"number\":300,\"title\":\"Writing Class For Code Conventions\",\"term\":\"sp19\",\"instructorId\":\"3\"}")
echo "  ->Req body incomplete: $test_2_4_2"
test_2_4_3=$(curl -X PATCH "http://localhost:8000/courses/3" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"6\",\"subject\":\"WR\",\"number\":300,\"title\":\"Writing Class For Code Conventions\",\"term\":\"sp19\",\"instructorId\":\"3\"}")
echo "  ->Unauthenticated user: $test_2_4_3"
test_2_4_4=$(curl -X PATCH "http://localhost:8000/courses/300" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"3\",\"subject\":\"WR\",\"number\":300,\"title\":\"Writing Class For Code Conventions\",\"term\":\"sp19\",\"instructorId\":\"3\"}")
echo "  ->No course by id: $test_2_4_4"
echo " "
echo " "
echo "5. DELETES a course DELETE courses/{id}"
echo "Successful Queries:"
test_2_5_1=$(curl -X DELETE "http://localhost:8000/courses/15" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Delete success: $test_2_5_1"
echo " "
echo "Failed Queries:"
test_2_5_2=$(curl -X DELETE "http://localhost:8000/courses/400" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Course not found: $test_2_5_2"
test_2_5_3=$(curl -X DELETE "http://localhost:8000/courses/6" -H "accept: */*" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"10\"}")
echo "  ->Unauthenticated user: $test_2_5_3"
echo " "
echo " "
echo "6. GET list of students enrolled in course GET courses/{id}/students"
echo "Successful Queries:"
test_2_6_1=$(curl -X GET "http://localhost:8000/courses/6/students" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Student List: $test_2_6_1"
echo " "
echo "Failed Queries:"
test_2_6_2=$(curl -X GET "http://localhost:8000/courses/6/students" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"4\"}")
echo "  ->Unauthorized user: $test_2_6_2"
test_2_6_3=$(curl -X GET "http://localhost:8000/courses/600/students" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->No course found: $test_2_6_3"
echo " "
echo " "
echo "7. Update enrollment for students POST /courses/{id}/students"
echo "Successful Queries:"
test_2_7_1=$(curl -X POST "http://localhost:8000/courses/5/students" -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer ${bearerToken}" -d "{\"id\":\"1\",\"add\":[\"4\",\"5\",\"6\"],\"remove\":[]}")
echo "  ->Admin Unenrolled/Enrolled students: $test_2_7_1"
test_2_7_2=$(curl -X POST "http://localhost:8000/courses/2/students" -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer ${bearerToken}" -d "{\"id\":\"2\",\"add\":[\"6\",\"7\",\"8\"],\"remove\":[\"5\"]}")
echo "  ->Instructor Unenrolled/Enrolled students: $test_2_7_2"
echo " "
echo "Failed Queries:"
test_2_7_3=$(curl -X POST "http://localhost:8000/courses/2/students" -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer ${bearerToken}" -d "{\"id\":\"3\",\"add\":[\"6\",\"7\",\"8\"],\"remove\":[\"7\"]}")
echo "  ->Instructor doesn't teach class: $test_2_7_3"
test_2_7_4=$(curl -X POST "http://localhost:8000/courses/200/students" -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer ${bearerToken}" -d "{\"id\":\"2\",\"add\":[\"6\",\"7\",\"8\"],\"remove\":[\"5\"]}")
echo "  ->Course not found: $test_2_7_4"
echo " "
echo " "
echo "8. Fetch CSV containing list of student enrollment GET /courses/{id}/roster"
echo "Successful Queries:"
test_2_8_1=$(curl -X GET "http://localhost:8000/courses/7/roster" -H "Authorization: Bearer ${bearerToken}" -H "accept: text/csv" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->CSV Response: $test_2_8_1"
echo " "
echo "Failed Queries:"
test_2_8_2=$(curl -X GET "http://localhost:8000/courses/700/roster" -H "Authorization: Bearer ${bearerToken}" -H "accept: text/csv" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Course not found: $test_2_8_2"
test_2_8_3=$(curl -X GET "http://localhost:8000/courses/7/roster" -H "Authorization: Bearer ${bearerToken}" -H "accept: text/csv" -H "Content-Type: application/json" -d "{\"id\":\"4\"}")
echo "  ->Unauthenticated user: $test_2_8_3"
echo " "
echo " "
echo "9. Return list containing asignment ids GET /courses/{id}/assignments"
echo "Successful Queries:"
test_2_9_1=$(curl -X GET "http://localhost:8000/courses/5/assignments" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"4\"}")
echo "  ->Class Assignments: $test_2_9_1"
echo " "
echo "Failed Queries:"
test_2_9_2=$(curl -X GET "http://localhost:8000/courses/5/assignments" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"400\"}")
echo "  ->Unauthenticated user: $test_2_9_2"
test_2_9_3=$(curl -X GET "http://localhost:8000/courses/500/assignments" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"4\"}")
echo "  ->No course was found: $test_2_9_3"
echo " "
echo " "
echo "============================================================================================================================================"
echo "=====================================================ASSIGNMENT TESTS======================================================================="
echo "============================================================================================================================================"
echo " "
echo "1. Create new assignment POST /assignments"
echo "Successful Queries:"
test_3_1_1=$(curl -X POST "http://localhost:8000/assignments" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"courseId\":\"5\",\"title\":\"New HW assignment\",\"points\":100,\"due\":\"2020-06-14T17:00:00-023:59\"}")
echo "  ->Created new assignment: $test_3_1_1"
echo " "
echo "Failed Queries:"
test_3_1_2=$(curl -X POST "http://localhost:8000/assignments" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"5\",\"courseId\":\"5\",\"title\":\"New HW assignment\",\"points\":100}")
echo "  ->Unauthenticated user: $test_3_1_2"
test_3_1_3=$(curl -X POST "http://localhost:8000/assignments" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"title\":\"New HW assignment\",\"points\":100}")
echo "  ->Req body incomplete: $test_3_1_3"
echo " "
echo " "
echo "2. Returns summary data on assignment GET /assignments/{id}"
echo "Successful Queries:"
test_3_2_1=$(curl -X GET "http://localhost:8000/assignments/8" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Assignment Summary: $test_3_2_1"
echo " "
echo "Failed Queries:"
test_3_2_2=$(curl -X GET "http://localhost:8000/assignments/123" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->No assignment by id: $test_3_2_2"
test_3_2_3=$(curl -X GET "http://localhost:8000/assignments/123" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"40\"}")
echo "  ->Unauthenticated user: $test_3_2_3"
echo " "
echo " "
echo "3. Partial update on data for assignment PATCH /assignments/{id}"
echo "Successful Queries:"
test_3_3_1=$(curl -X PATCH "http://localhost:8000/assignments/8" -H "Authorization: Bearer ${bearerToken}" -H "accept: */*" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"courseId\":\"8\",\"title\":\"Updated Assignment\",\"points\":100,\"due\":\"2019-06-14T17:00:00-07:00\"}")
echo "  ->Update for assignment: $test_3_3_1"
echo " "
echo "Failed Queries:"
test_3_3_2=$(curl -X PATCH "http://localhost:8000/assignments/8" -H "Authorization: Bearer ${bearerToken}" -H "accept: */*" -H "Content-Type: application/json" -d "{\"id\":\"1\",\"title\":\"Updated Assignment\",\"points\":100,\"due\":\"2019-06-14T17:00:00-07:00\"}")
echo "  ->Req body is incomplete: $test_3_3_2"
test_3_3_3=$(curl -X PATCH "http://localhost:8000/assignments/8" -H "Authorization: Bearer ${bearerToken}" -H "accept: */*" -H "Content-Type: application/json" -d "{\"id\":\"10\",\"courseId\":\"8\",\"title\":\"Updated Assignment\",\"points\":100,\"due\":\"2019-06-14T17:00:00-07:00\"}")
echo "  ->Unauthorized user: $test_3_3_3"
echo " "
ehco " "
echo "4. Delete a assignment, all its submissions DELETE /assignments/{id}"
echo "Successful Queries:"
test_3_4_1=$(curl -X DELETE "http://localhost:8000/assignments/16" -H "Authorization: Bearer ${bearerToken}" -H "accept: */*" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->Successful Deletion: $test_3_4_1"
echo " "
echo "Failed Queries:"
test_3_4_2=$(curl -X DELETE "http://localhost:8000/assignments/7" -H "Authorization: Bearer ${bearerToken}" -H "accept: */*" -H "Content-Type: application/json" -d "{\"id\":\"5\"}")
echo "  ->Unauthorized user: $test_3_4_2"
test_3_4_3=$(curl -X DELETE "http://localhost:8000/assignments/600" -H "Authorization: Bearer ${bearerToken}" -H "accept: */*" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->No assignment found by id: $test_3_4_3"
echo " "
echo " "
echo "5. Return list of all submissions for assignment. paginated GET /assignments/{id}/submissions"
echo "Successful Queries:"
test_3_5_1=$(curl -X GET "http://localhost:8000/assignments/4/submissions?page=1" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"1\"}")
echo "  ->List submissions: $test_3_5_1"
echo " "
echo "Failed Queries:"
test_3_5_2=$(curl -X GET "http://localhost:8000/assignments/4/submissions?page=1" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"5\"}")
echo "  ->Unauthorized user: $test_3_5_2"
echo " "
echo " "
echo "6. Create new submission for assignment(student entrypoint) POST /assignments/{id}/submissions"
echo "Successful Queries:"
test_3_6_1=$(curl -X POST "http://localhost:8000/assignments/3/submissions" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"5\",\"assignmentId\":\"3\",\"studentId\":\"5\",\"timestamp\":\"2019-06-14T17:00:00-07:00\",\"file\":\"file/path/distacne\"}")
echo "  ->Succesful upload: $test_3_6_1"
echo " "
echo "Failed Queries:"
test_3_6_2=$(curl -X POST "http://localhost:8000/assignments/300/submissions" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"5\",\"assignmentId\":\"3\",\"studentId\":\"5\",\"timestamp\":\"2019-06-14T17:00:00-07:00\",\"file\":\"file/path/distacne\"}")
echo "  ->No assignmnent by id: $test_3_6_2"
test_3_6_3=$(curl -X POST "http://localhost:8000/assignments/3/submissions" -H "Authorization: Bearer ${bearerToken}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"50\",\"assignmentId\":\"3\",\"studentId\":\"5\",\"timestamp\":\"2019-06-14T17:00:00-07:00\",\"file\":\"file/path/distacne\"}")
echo "  ->Unauthorized user: $test_3_6_3"
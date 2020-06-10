function paginationQuery(obj, schema) {
    let query = '';
    let firstField = true;
    Object.keys(schema).forEach((field) => {
        let temp = '';
        if (obj[field]) {
            if(field != 'page'){
                temp = `${field}=?`;
                if(firstField){
                    firstField = false;
                    query += temp;
                }else {
                    query += ' AND ' + temp;
                }
            }
        }
    });
    return query;
}
exports.paginationQuery = paginationQuery;

function paginationArray(obj, schema) {
    let arr = [];
    Object.keys(schema).forEach((field) => {
        if (obj[field] != null) {
            console.log("field: ", obj[field]);
            arr.push(obj[field]);
        }
    });
    console.log("NEW arr: ", arr);
    return arr;
}
exports.paginationArray = paginationArray;
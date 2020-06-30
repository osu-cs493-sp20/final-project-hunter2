const express = require('express');
const morgan = require('morgan');
const api = require('./api');

const { enterErrorRequest } = require('./models/errors');

const app = express();
const port = process.env.PORT || 8033;
const cors = require('cors');
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.static('public'));

app.use('/', api);

app.use('*', async function (req, res, next) {
    // All error messages are routed through here. Stored to db then sent out to user.
    if(!!req.errorMessage){
        try {
            await enterErrorRequest(req.errorCode, req.errorMessage);
            res.status(req.errorCode).send({
                error: req.errorMessage
            });
        } catch (err) {
            res.status(500).json({
                error: "Client ran into problem accessing server"
            });
        }
    }else {
        res.status(404).json({
            error: "Requested resource " + req.originalUrl + " does not exist"
        });
    }
});

app.listen(port, function() {
    console.log("== Server running on port", port);
});

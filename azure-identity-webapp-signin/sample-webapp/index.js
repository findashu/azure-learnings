import dotenv from "dotenv";
import express from 'express';
import path from 'path';
import session from "express-session";
import cookieParser from "cookie-parser";
import {fileURLToPath} from 'url';

// 👇️ "/home/borislav/Desktop/javascript/index.js"
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// import logger from 'morgan'

import indexRouter from "./routes/indexRoute.js"
import userRouter from "./routes/usersRoute.js"
import authRouter from "./routes/authRoute.js"

dotenv.config({
    path: "./.env",
});
  

const app = express();

app.use(session({
    secret: process.env.EXPRESS_SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
        httpOnly: true,
        secure: false, // set this to true on production
    }
}));



app.set('views',  path.join(__dirname, 'views'));
app.set('view engine', 'hbs');

// app.use(logger('dev'));
app.use(express.json());
app.use(cookieParser());
app.use(express.urlencoded({ extended: false }));
// app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', userRouter);
app.use('/auth', authRouter);

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    res.status(404).json({message:"Page not found"})
});

// // error handler
app.use(function (err, req, res, next) {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    // render the error page
    res.status(err.status || 500);
    res.render('error');
});

app.listen(3000, () => console.log("App up and running on port 3000"));
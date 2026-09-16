// 引入套件
const express = require("express");
const mongoose = require('mongoose');
const router = express.Router();

// 連接到 MongoDB 資料庫，第一個是本地端，第二個是雲端
// mongoose.connect('mongodb://localhost:27017/students');
mongoose.connect('mongodb+srv://wei:<db_password>@cluster0.rxsqx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'); // 連結雲端Atlas
const db = mongoose.connection;

// 與資料庫連線發生錯誤時
db.on('error', console.error.bind(console, 'Connection fails!'));

// 與資料庫連線成功連線時
db.once('open', function () {
    console.log('Connected to database...');
});

// 該collection的格式設定
const todoSchema = new mongoose.Schema({
    name: { //事項名稱
        type: String, //設定該欄位的格式
        required: true //設定該欄位是否必填
    },
    pic: { //是否已完成
        type: String,
        required: true,
    },
    Price: { //新增的時間
        type: Number,
        required: true
    },
})

const Todo = mongoose.model('Todo', todoSchema);

// 取得全部資料
// 使用非同步，才能夠等待資料庫回應
router.get("/", async (req, res) => {
    // 使用try catch方便Debug的報錯訊息
    try {
        // 找出Todo資料資料表中的全部資料
        const todo = await Todo.find();
        // 將回傳的資訊轉成Json格式後回傳
        res.json(todo);
    } catch (err) {
        // 如果資料庫出現錯誤時回報 status:500 並回傳錯誤訊息 
        res.status(500).json({ message: err.message })
    }
});

// 新增待辦事項
// 將Method改為Post
router.post("/", async (req, res) => {
    // $.post('students', { name, age, grade }, function (newStudent) {
    //     $('#student-list').append(`<tr><td>${newStudent.name}</td><td>${newStudent.age}歲</td><td>${newStudent.grade}年級</td></tr>`);
    //     $('#add-student-form').reset();
    // });
    // 從req.body中取出資料
    const todo = new Todo({
        name: req.body.name,
        pic: req.body.age,
        price: req.body.grade,
    });
    try {
        // 使用.save()將資料存進資料庫
        const newTodo = await todo.save();
        // 回傳status:201代表新增成功 並回傳新增的資料
        res.status(201).json(newTodo);
    } catch (err) {
        console.error("Error:", err.message);

        // 錯誤訊息發生回傳400 代表使用者傳入錯誤的資訊
        res.status(400).json({ message: err.message })
    }
});


// Export 該Router
module.exports = router;
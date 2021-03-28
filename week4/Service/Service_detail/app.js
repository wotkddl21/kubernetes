const express = require('express');
const mongoose = require('mongoose');
const fs = require('fs');
var app = express();
var ret='before';
function connectDB(){
        var databaseUrl='mongodb://mongo-cluster-ip.default.svc.cluster.local:27017';
        console.log('try to connect to db');
        mongoose.Promise = global.Promise;
        mongoose.connect(databaseUrl,{useNewUrlParser:true,useUnifiedTopology:true},function(err,db){

                if(err){
                        console.log('connection error' + err);
                        ret = 'connection error'+ err;
                        return false;
                }
                console.log('connection completed');
                ret = 'connection completed';
                return true;
        });
};

app.get('/',function(req,res){
        fs.readFile(__dirname+'/public/hello.html','utf8',function(err,data){
                res.send(data);
        });
})

app.get('/connect',function(req,res){
        connectDB();
        res.send("connect to DB");
})
app.listen(3000,function(){
        console.log("open at 3000 port");
})

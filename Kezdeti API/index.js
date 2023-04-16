const express = require('express')
const app = express()
const mongoose = require('mongoose')
const dotenv = require('dotenv')

// Import routes
const userRoutes = require('./routes/users')
const adminRoutes = require('./routes/admin')
const doctorRoutes = require('./routes/doctor')
const patientRoutes = require('./routes/patient')

dotenv.config()

// Connect to DB
mongoose.connect(process.env.DB_CONNECT)
    .then(() => console.log("Connected to DB successfully!"))
    .catch((err) => console.log("Failed to connect to the DB."))

// Middlewares
app.use(express.json())

// Route middlewares
app.use('/users', userRoutes)
app.use('/admin', adminRoutes)
app.use('/doctor', doctorRoutes)
app.use('/patient', patientRoutes)
app.use('/uploads', express.static('uploads'))

app.listen(3000, () => console.log("Server is up and running at port 3000..."))
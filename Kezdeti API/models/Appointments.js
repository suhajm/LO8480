const mongoose = require('mongoose')

const appointmentsSchema = new mongoose.Schema({
    _id: {
        type: String,
        required: true
    },
    doctorID: {
        type: String,
        required: true
    },
    patientID: {
        type: String,
        required: false
    },
    name: {
        type: String,
        required: true
    },
    date: {
        type: Date,
        required: true
    }
})

module.exports = mongoose.model('Appointments', appointmentsSchema)
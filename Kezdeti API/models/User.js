const mongoose = require('mongoose')

const userSchema = new mongoose.Schema({
    role: {
        type: String,
        required: true,
        min: 5,
        max: 7
    },
    gender: {
        type: String,
        required: true
    },
    firstname: {
        type: String,
        required: true,
        min: 3,
        max: 255
    },
    lastname: {
        type: String,
        required: true,
        min: 3,
        max: 255
    },
    spec_ill: {
        type: String,
        required: false,
    },
    introduction: {
        type: String,
        required: false
    },
    country: {
        type: String,
        required: false
    },
    state: {
        type: String,
        required: false
    },
    city: {
        type: String,
        required: false
    },
    postcode: {
        type: String,
        required: false
    },
    street: {
        type: String,
        required: false
    },
    house: {
        type: String,
        required: false
    },
    phone: {
        type: String,
        required: false
    },
    email: {
        type: String,
        required: true,
        max: 255,
        min: 6
    },
    password: {
        type: String,
        required: true,
        max: 1024,
        min: 6
    },
    image: {
        type: String,
        required: false
    }
})

module.exports = mongoose.model('User', userSchema)
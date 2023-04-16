const router = require('express').Router()
const Appointments = require('../models/Appointments')
const authentication = require("../auth.js")

router.get('/getAppointments', authentication, async (req, res) => {

    const appointments = await Appointments.find({doctorID: req.User._id})

    var neededInfo = []
    for (data in appointments) {
        neededInfo.push({
            _id: appointments[data]._id,
            doctorID: appointments[data].doctorID,
            patienID: appointments[data].patientID,
            name: appointments[data].name,
            date: appointments[data].date
        })
    }

    res.json(neededInfo)

})

router.post('/addAppointment', authentication, async (req, res) => {

    if (req.body.role != "doctor") {
        res.send('Access denied.')
    } else {

        const appointment = new Appointments({

            _id: req.body._id,
            doctorID: req.User._id,
            patientID: "",
            name: req.body.name,
            date: req.body.date
        })

        try {
            await appointment.save()
            res.send('success')
        } catch(err) {
            res.status(400).send(err)
        }

    }

})

router.delete('/deleteAppointment', authentication, async (req, res) => {

    if (req.body.role != "doctor") {
        res.send('Access denied.')
    } else {

        try {
            await Appointments.deleteOne(
                {
                    _id: req.body._id,
                    doctorID: req.User._id
                }
                )
            res.send('success')
        } catch (err) {
            res.send("Error deleting user.")
        }

    }

})

module.exports = router
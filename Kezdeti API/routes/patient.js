const router = require('express').Router()
const Appointments = require('../models/Appointments')
const authentication = require("../auth.js")

router.post('/getAppointments', authentication, async (req, res) => {

    if (req.body.role != "patient") {
        res.send('Access denied.')
    } else {

        const appointments = await Appointments.find(
            {
                doctorID: req.body.doctorID,
                patientID: ""
            })

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

    }

})


module.exports = router
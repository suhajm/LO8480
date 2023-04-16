const router = require('express').Router()
const User = require('../models/User')
const authentication = require("../auth.js")

router.delete('/deleteUser', authentication, async (req, res) => {

    if (req.body.role != "admin") {
        res.send('Access denied.')
    } else {

        try {
            await User.deleteOne({_id: req.body._id})
            res.send('success')
        } catch (err) {
            res.send("Error deleting user.")
        }

    }
})

module.exports = router
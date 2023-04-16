const router = require('express').Router()
const User = require('../models/User')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
const authentication = require("../auth.js")
const multer = require('multer')

const storage = multer.diskStorage({

    destination: function(req, file, cb) {
        cb(null, './uploads')
    },
    filename: function(req, file, cb) {
        cb(null, new Date().toISOString() + file.originalname)
    } 

}) 

const fileFilter = (req, file, cb) => {
    if (file.mimetype == 'image/jpeg' || file.mimetype == 'image/png' || file.mimetype == 'image/heic') {
        // accept a file
        cb(null, true)
    } else {
        // reject a file
        cb(null, false)
    }

}

const upload = multer(
    {
        storage: storage, 
        limits: {fileSize: 1024 * 1024 * 5},
        fileFilter: fileFilter
    })

router.post('/register', async (req, res) => {
  
      // Checking if the user is already in the database
      const emailExist = await User.findOne({email: req.body.email})
      if (emailExist) {
          return res.status(400).send('Email already exists')
      }
  
      // Hash the password
      const salt = await bcrypt.genSalt(10)
      const hashedPassword = await bcrypt.hash(req.body.password, salt)
  
      // Create a new user
      const user = new User({
          role: req.body.role, 
          gender: req.body.gender,
          firstname: req.body.firstname,
          lastname: req.body.lastname,
          spec_ill: "",
          introduction: "",
          country: "",
          state: "",
          city: "",
          postcode: "",
          street: "",
          house: "",
          phone: "",
          email: req.body.email,
          password: hashedPassword,
          image: "http://192.168.1.71:3000/uploads/2022-08-11T10:28:40.379Zdefault.png"
      })
  
      try {
          await user.save()
          res.send("success")
      }
      catch(err) {
          res.status(400).send(err)
      }
})

router.post('/login', async (req, res) => {

    // Checking if the email exists in the database
    const user = await User.findOne({email: req.body.email})
    if (!user) {
        res.send('Invalid email or password')
    } else {
     
        // If password is correct
        const validPass = await bcrypt.compare(req.body.password, user.password)
        if (!validPass) {
            res.send('Invalid email or password')
        } else {
     
            // Create and assign a token
            const token = jwt.sign({_id: user._id}, process.env.TOKEN_SECRET)
     
            const info = 
            {
                "token": token,
                "role": user.role
            }
     
            res.header('auth-token', token).send(info)
        }
     }
   
})

router.get('/getUserInfo', authentication, async (req, res) => {

    const user = await User.findOne({_id: req.User._id})
    if (!user) {
        res.send('Cannot find user.')
    }

    const neededInfo = 
    {
        "_id": user._id,
        "role": user.role,
        "gender": user.gender,
        "firstname": user.firstname,
        "lastname": user.lastname,
        "email": user.email,
        "spec_ill": user.spec_ill,
        "image": user.image,
        "introduction": user.introduction,
        "phone": user.phone,
        "country": user.country,
        "postcode": user.postcode,
        "city": user.city,
        "street": user.street,
        "house": user.house,
        "image": user.image
    }

    res.json(neededInfo)
})

router.patch('/updateProfilePic', authentication, upload.single('image'), async (req, res) => {

    var imageUrl = ""
    if (req.file == undefined) {
        imageUrl = "uploads/2022-08-11T10:28:40.379Zdefault.png"
    } else {
        imageUrl = req.file.path
    }

    const update =  await User.updateOne(
        {_id: req.User._id },
        {$set: 
            {
                image: "http://192.168.1.69:3000/" + imageUrl
            }
        }
    )

    if (update.modifiedCount > 0) {
        res.send('success')
    } else {
        res.send('error')
    }

})

router.patch('/update', authentication, async (req, res) => {

    const update =  await User.updateOne(
        {_id: req.User._id },
        {$set: 
            {
                gender: req.body.gender,
                firstname: req.body.firstname,
                lastname: req.body.lastname,
                spec_ill: req.body.spec_pos,
                introduction: req.body.introduction,
                country: req.body.country,
                postcode: req.body.postcode,
                state: req.body.state,
                city: req.body.city,
                street: req.body.street,
                house: req.body.house,
                phone: req.body.phone,
                email: req.body.email2
            }
        }
    )

    if (update.modifiedCount > 0) {
        res.send('success')
    } else {
        res.send('error')
    }

})

router.patch('/updatePassword', authentication, async (req, res) => {

    const user = await User.findOne({_id: req.User._id})
    if (!user) {
        res.send('Cannot find user.')
    } else {

        const validPass = await bcrypt.compare(req.body.oldPassword, user.password)
        if (!validPass) {
            res.send('Invalid password')
        } else {
    
            const salt = await bcrypt.genSalt(10)
            const hashedPassword = await bcrypt.hash(req.body.newPassword, salt)
        
            const update =  await User.updateOne(
                {_id: req.User._id },
                {$set: 
                    {
                        password: hashedPassword
                    }
                }
            )
        
            if (update.modifiedCount > 0) {
                res.send('success')
            } else {
                res.send('error')
            }
    
        }

    }
   
})

router.get('/getDoctors', authentication, async (req, res) => {

    const doctor = await User.find({role: 'doctor'})
    var neededInfo = []
    for (data in doctor) {
       neededInfo.push({
           _id: doctor[data]._id,
           role: doctor[data].role,
           gender: doctor[data].gender,
           firstname: doctor[data].firstname,
           lastname: doctor[data].lastname,
           email: doctor[data].email,
           spec_ill: doctor[data].spec_ill,
           image: doctor[data].image,
           introduction: doctor[data].introduction,
           phone: doctor[data].phone,
           country: doctor[data].country,
           postcode: doctor[data].postcode,
           city: doctor[data].city,
           street: doctor[data].street,
           house: doctor[data].house
       })
    }
    res.json(neededInfo)
})

router.get('/getPatients', authentication, async (req, res) => {

    const patient = await User.find({role: 'patient'})
    var neededInfo = []
    for (data in patient) {
       neededInfo.push({
           _id: patient[data]._id,
           role: patient[data].role,
           gender: patient[data].gender,
           firstname: patient[data].firstname,
           lastname: patient[data].lastname,
           email: patient[data].email,
           spec_ill: patient[data].spec_ill,
           image: patient[data].image
       })
    }
    res.json(neededInfo)
})

module.exports = router
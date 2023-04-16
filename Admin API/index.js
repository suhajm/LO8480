const express = require('express')
const app = express()
app.use(express.json());

var admin = require('firebase-admin');

var serviceAccount = require('./idopontfoglalo-5b900-firebase-adminsdk-5p6k5-b4f80ba32c.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
})

const db = admin.firestore()

app.delete('/delete', async (req, res) => {

    var idToken = req.body.idToken

    admin.auth()
    .verifyIdToken(idToken)
    .then(async (decodedToken) => {
        const currentUserUid = decodedToken.uid;
        const userRef = db.collection('users').doc(currentUserUid);
        const doc = await userRef.get();
        if (!doc.exists) {
            res.send("There is no user who has the given uid!")
        } else {
            var role = doc.data().role
            
            if (role == "admin") {

                var uid = req.body.uid
            
                admin.auth()
                .deleteUser(uid)
                .then(async () => {
                    await db.collection('contacts').doc(uid).delete()
                    .then(async () => {
                        await db.collection('addresses').doc(uid).delete()
                        .then(async () => {
                            await db.collection('users').doc(uid).delete()
                            .then(() => {
                                res.send("Deleted successfully")
                            })
                            .catch(() => {
                                res.send("Delete failed")
                            })
                        })
                        .catch(() => {
                            res.send("Delete failed")
                        })
                    })
                    .catch(() => {
                        res.send("Delete failed")
                    })
                    
                })
                .catch((error) => {
                    res.send("Delete failed")
                });
            
              } else {
                res.send("You have no rights to delete!")
              }

        }
    })
    .catch((error) => {
        res.send("Invalid token!")
    });

})

app.post('/createUser', async (req, res) => {

    var idToken = req.body.idToken

    admin.auth()
    .verifyIdToken(idToken)
    .then(async (decodedToken) => {
        const currentUserUid = decodedToken.uid;
        const cityRef = db.collection('users').doc(currentUserUid);
        const doc = await cityRef.get();
        if (!doc.exists) {
            res.send("There is no user who has the given uid!")
        } else {
            admin.auth()
            .createUser({
                email: req.body.email,
                emailVerified: true,
                password: req.body.password,
                displayName: req.body.lastname + " " + req.body.firstname,
                disabled: false,
            })
            .then(async (userRecord) => {
                const data = {
                    role: "admin",
                    gender: req.body.gender,
                    title: req.body.title,
                    lastname: req.body.lastname,
                    firstname: req.body.firstname,
                    uid: userRecord.uid,
                    profilePicURL: "https://firebasestorage.googleapis.com/v0/b/idopontfoglalo-5b900.appspot.com/o/profilePictures%2Fuser.jpg?alt=media&token=84694973-bb2c-40b8-86b0-b98796735674"
                  };

                  await db.collection('users').doc(userRecord.uid).set(data)
                  .then(async () => {

                    const addressData = {
                        uid: userRecord.uid
                    }

                    await db.collection('addresses').doc(userRecord.uid).set(addressData)
                    .then(async () => {

                        await db.collection('contacts').doc(userRecord.uid).set(addressData)
                        .then(() => {

                            res.send("Admin created successfully")

                        })
                        .catch(() => {
                            res.send("Error creating new user")
                        })

                    })
                    .catch(() => {
                        res.send("Error creating new user")
                    })

                  })
                  .catch(() => {
                    res.send("Error creating new user")
                  })
            })
            .catch((error) => {
                res.send('Error creating new user')
            });
        }
    })
    .catch((error) => {
        res.send("Invalid token!")
    });

})

app.listen(3000, () => console.log("Server is up and running at port 3000..."))
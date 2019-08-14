## StayingAlive

StayingAlive was a university project which required us to create an iOS application to work in conjunction with the IoT device we had created.
The IoT device I created was a fish tank monitor that automatically adjusted temperature and water level for a fish tank. 
It utilised a Raspberry Pi, temperature sensor, ultrasonic range sensor, water pump and heating device to look after your fish tank.

## Technology and knowledge

The technologies used during the development of this mobile application included Xcode, Swift and Firebase. I learnt the basics of using the Xcode integrated development environment and how to use Swift to retrieve data from Firebase to present it in real-time in different graphical formats.

## Acknowledgements
The circular progress bars on the home page were created using [MKMagneticProgress]( https://github.com/malkouz/MKMagneticProgress) and the graphs created in the data page used [ChartProgressBar](https://github.com/hadiidbouk/ChartProgressBar-iOS). 

## Screenshots

###### Login menu - The login verifies with the Firebase database to retrieve the correct data for the user
<p align="center"><img src="Screenshots/Login.jpg" height="300"></p>


###### Home screen -The 2 gauges update in real-time based on the values collected by the IoT sensors. If the user sets their settings to 'manual', the 2 devices buttons will become active and allow the user to manually turn on or off the heating device and water pump. 
<p align="center"><img src="Screenshots/Home.jpg" height="300"></p>


###### Historic data - Users can view their fish tanks historic water level and temperatures.
<p align="center"><img src="Screenshots/Historic.jpg" height="300"></p>


###### Settings -Users can set their water tank height and what temperature and water level they would like the device to maintain their water tank at.
<p align="center"><img src="Screenshots/Setting.jpg" height="300"></p>


###### Camera - The IoT device had a camera attached which allows the users to remotely take a photo to view their fish tank.
<p align="center"><img src="Screenshots/Camera.jpg" height="300"></p>

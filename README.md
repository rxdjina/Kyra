# MetaU Summer 2022 Project

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
1. [Schema](#Schema)

## Overview
### Description
Application allows users to join music sessions with friends.

### App Evaluation
- **Category:** Music
- **Mobile:** Application would be primarily developed for mobile. However, could perhaps also be web-based or offered on smart TVs
- **Story:** Create and join music sessions with friends. User can then save collabortive playlists and export it to other music platforms
- **Market:** Could be used by any individual. Users have option to configure the settings of sessions to restrict explicit music. Users are also limited in how many songs they can add at once in order to limit spam.
- **Habit:** Application could be used as frequently as needed, depending on the prefrences of users.
- **Scope:** Would start with private music sessions. Could expand to inlcude additional features within each session such as karaoke modes, or games as well as music dicovery.

## Product Spec
### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can log in and log out
* All corresponding settings saved
* Users can create and join sessions
* User can add song to queue
* All connected devices should sync up in real-time
* User can view previous sessions
* User can create collaborative playlist of songs from finished sessions
* User is able to export playlist to other music platforms
* Ability to remove a user from session

**Optional Nice-to-have Stories**

* Implement public sessions based on genre
* Karaoke Mode
   * Implement audio visualizer & in sync lyrics
* Ability to edit session settings (e.g., banning explicit songs)
* Chat Feature
* Email validation
* Spam/Bot Prevention
* Song recommendations based on current session

### 2. Screen Archetypes

* Login 
* Register - User signs up or logs into their account
* Home Screen -  User can see their current active sessions as well as create of join new ones
* Sessions Screen - User can see songs played in session and add new ones
  * Karaoke Screen (Optional) - User selects song and sings along. Song lyrics are automatically loaded and synced.
* Song Selection Screen - Users can search for a song, or have one recommended and add it to the queue
* Settings Screen - Allows users to edit current setting 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home
* Sessions 
* History
* Settings

**Flow Navigation** (Screen to Screen)
* Login
  * Sign up -> Welcome Screen 
* Home Screen
* Session Screen -> Session
  * Song Selection Screen -> Detailed View
  * Karaoke Mode
* History
* Settings

## Wireframes
[App Prototype](https://www.figma.com/file/ECYnRRv39Wayh3vv3ngaiC/MetaU-Summer-2022-Capstone-Project---App-Prototype?node-id=0%3A1)

## Schema 
### Models
#### Post

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for session |
   | userId        | String   | unique id for users |
   | userCount     | Number   | number of active users in session |
   | queueCount    | Number   | number of song in queue |
   | sessionDict   | Dictionary| all songs played in session |
   | createdAt     | DateTime | date when session was created |
   | endedAt       | DateTime | date when session ended |
   
### Networking
#### List of network requests by screen
   - Home Screen
      - (Create/POST) Create new session object
      - (Delete) Delete existing session object
   - Session
      - (Read/GET) User objects of those within session 
      - (Read/GET) Song information (e.g., name, artist, album cover, lyrics)
      - (Update/PUT) Song queue 
      - (Create/POST) Create playlist of songs played in queue
    
#### [OPTIONAL:] Existing API Endpoints

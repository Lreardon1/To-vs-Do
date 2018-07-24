# To vs Do

An app that allows you to create your own to do list and see how productive your friends are in order to compete to see who can be the most productive.

## Audience

People who tend to procrastinate but are motivated by competition

## Experience

A user opens the app and creates a new account. They can then add their friends from their contact list before they start using the app. The user will be able to create to do list items, mark them as complete, and see how much their friends have completed. 

# Technical

## Models

Users:
    Contains a username, profile picture, list of to do items, list of completed items, and statistics on completed tasks

Todo Item:
    Contains a title and a due date, possibly a short description

## Views

TodoItemTableViewCell:
    displays title of todo item and date to complete by

FriendStatsTableViewCell: 
    displays friend's name, profile picture, and statistics

## Controllers

MVP: 
- LoginViewController
- CreateUsernameViewController
- HomeViewController
- ProfileViewController
- CompletedTasksViewController
- FriendsListViewController
- FindFriendsViewController

Additional:
- AchievementsViewController

## Others

# Weekly Milestones

## Week 4 - Usable Build

- Set up cocoa pods
- Set up Firebase authentication
- Set up login flow
- Create ability to add to do elements
- Create ability to mark to do elements as completed
- Set up completed elements tab
- Set up finding friends functionality 
- Set up viewing Friends stats

## Week 5 - Finish Features

- Add Achievements 
- Add challenge system

## Week 6 - Polish



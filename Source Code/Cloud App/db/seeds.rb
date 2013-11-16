# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

    # Creates a Admin user

User.create(    userName: "Admin", firstName: "Ray",
                lastName: "Misomali", password: "foobar", password_confirmation: "foobar",
                email: "Admin@example.com", userType: 0, status: 1)
                
User.create(    userName: "epere250", firstName: "Ernesto",
                lastName: "Perez", password: "foobar", password_confirmation: "foobar",
                email: "epere250@fiu.edu", userType: 0, status: 1)
                
User.create(    userName: "hsuar001", firstName: "Humberto",
                lastName: "Suarez", password: "foobar", password_confirmation: "foobar",
                email: "hsuar001@fiu.edu", userType: 0, status: 1)
                
User.create(    userName: "kdiaz020", firstName: "Kevin",
                lastName: "Diaz", password: "foobar", password_confirmation: "foobar",
                email: "kdiaz020@fiu.edu", userType: 0, status: 1)
                
User.create(    userName: "jmend010", firstName: "Jamez",
                lastName: "Mendez", password: "foobar", password_confirmation: "foobar",
                email: "jmend010@fiu.edu", userType: 0, status: 1)                                
    
    # Creates a Record Keeper user

User.create(    userName: "rkeeper", firstName: "Steve",
                lastName: "Luis", password: "foobar", password_confirmation: "foobar",
                email: "rkeeper@example.com", userType: 1, status: 1)
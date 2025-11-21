import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           
          SizedBox(
            width: double.infinity,
            height: 260,
            child: Image.asset(
              "assets/images/profile_bg.png",
              fit: BoxFit.cover,
            ),
          ),

           
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),
 
                  Row(
                    children: [
                      GestureDetector(child: Icon(Icons.arrow_back, color: Colors.white),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      const Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 24),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Avatar section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              AssetImage("assets/avatar.png"),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Anni",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "anni@gmail.com",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Registered Since Dec 202X",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),


   ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('Transaction History'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      
                    },  
   ),

    ListTile(
                    leading: const Icon(Icons.door_back_door_outlined, color: Colors.red,),
                    title: const Text('Log Out', style: TextStyle(color: Colors.red),),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      
                    },
    )
                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

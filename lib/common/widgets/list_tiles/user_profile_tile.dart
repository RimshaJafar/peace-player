import 'package:ecommerce_app/common/widgets/images/p_circular_image.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PUserProfileTile extends StatelessWidget {
  const PUserProfileTile({
    super.key, required Function() onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PCircularImage(image: PImages.userPlaceholder,width: 50, overlayColor:null,height: 50,padding: 0,),
      title: Text("Coding With Zainab",style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),),
      subtitle:Text("zainabqayyum18@gmail.com",style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),),
      trailing: IconButton(onPressed: (){}, icon: Icon(Iconsax.edit,color: Colors.white,)),
    );
  }
}

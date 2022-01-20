import 'package:vivity/features/item/models/item_model.dart';

const String mapBoxToken = "pk.eyJ1IjoiaGVrbm9uIiwiYSI6ImNreHVmemwyeDFtYWIyc212cGx3bmJudHIifQ.wHNQF9MwcyfeR06Isivv3g";
const String ipApiPath = 'http://ip-api.com/json';
const ItemModel itemModelDemo = ItemModel(
  businessName: "Vivity",
  price: 23.4,
  images: ["https://pub.dev/static/img/ff-banner-desktop-2x.png?hash=48nbn83rjrlg52rnkp4lq1npafu8jsve"],
  reviews: [
    Review(
      posterName: "Heknon",
      pfpImage: "https://pub.dev/static/img/pub-dev-logo-2x.png?hash=umitaheu8hl7gd3mineshk2koqfngugi",
      rating: 4.5,
      textContent: "test text very cool",
      imageUrls: ["https://raw.githubusercontent.com/material-foundation/google-fonts-flutter/main/readme_images/google_fonts_folder.png"],
    ),
  ],
  itemStoreFormat: ItemStoreFormat(
    title: "Nice Item!",
    subtitle: "Ooooo subtitle",
    description: "A very lengthy description",
    modificationButtons: [
      ModificationButton(
        name: "name",
        data: ["S", "M", "L"],
        dataType: ModificationButtonDataType.text,
        modificationButtonSide: ModificationButtonSide.left,
      ),
    ],
  ),
  brand: "Hanes",
  category: "Hoodies",
  tags: ["Cool", "New!", "Hoodie"],
  stock: 34,
);

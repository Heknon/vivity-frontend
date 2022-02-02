import 'package:vivity/features/item/models/item_model.dart';

const String mapBoxToken = "pk.eyJ1IjoiaGVrbm9uIiwiYSI6ImNreHVmemwyeDFtYWIyc212cGx3bmJudHIifQ.wHNQF9MwcyfeR06Isivv3g";
const String ipApiPath = 'http://ip-api.com/json';
const ItemModel itemModelDemo = ItemModel(
  businessName: "Vivity",
  price: 23.4,
  images: ["https://m.media-amazon.com/images/I/61n+vIfzOKL._AC_UX679_.jpg"],
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
        name: "Size",
        data: ["S", "M", "L"],
        dataType: ModificationButtonDataType.text,
        modificationButtonSide: ModificationButtonSide.right,
      ),
      ModificationButton(
        name: "Color",
        data: [0xff325a4f, 0xfffcb944, 0xff163353, 0xffba2435],
        dataType: ModificationButtonDataType.color,
        modificationButtonSide: ModificationButtonSide.left,
      ),
      ModificationButton(
        name: "Type",
        data: ["https://www.pexels.com/photo/1640777/download/", "https://images.immediate.co.uk/production/volatile/sites/30/2020/08/chorizo-mozarella-gnocchi-bake-cropped-9ab73a3.jpg"],
        dataType: ModificationButtonDataType.image,
        modificationButtonSide: ModificationButtonSide.center,
      ),
      ModificationButton(
        name: "dType",
        data: [0xff325a4f, 0xfffcb944, 0xff163353, 0xff325a4f, 0xfffcb944, 0xff163353],
        dataType: ModificationButtonDataType.color,
        modificationButtonSide: ModificationButtonSide.right,
      ),
    ],
  ),
  brand: "Hanes",
  category: "Hoodies",
  tags: ["Cool", "New!", "Hoodie"],
  stock: 34,
);

const ItemModel itemModelDemo2 = ItemModel(
  businessName: "Vivity",
  price: 13.9,
  images: ["https://m.media-amazon.com/images/I/81iyCcqLI6L._AC_SY879._SX._UX._SY._UY_.jpg", "https://m.media-amazon.com/images/I/61n+vIfzOKL._AC_UX679_.jpg"],
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
    title: "Hanes Hoodie - EcoSmart fdsf dsfdsfdsjfdoi",
    subtitle: "Ooooo subtitle",
    description: "A very lengthy description",
    modificationButtons: [
      ModificationButton(
        name: "Color",
        data: [0xff325a4f, 0xfffcb944, 0xff163353, 0xff325a4f, 0xfffcb944, 0xff163353],
        dataType: ModificationButtonDataType.color,
        modificationButtonSide: ModificationButtonSide.left,
      ),
      ModificationButton(
        name: "Color Type",
        data: [0xff325a4f, 0xfffcb944],
        dataType: ModificationButtonDataType.color,
        modificationButtonSide: ModificationButtonSide.center,
      ),
      ModificationButton(
        name: "Size",
        data: ["S", "M", "L"],
        dataType: ModificationButtonDataType.text,
        modificationButtonSide: ModificationButtonSide.right,
      ),
    ],
  ),
  brand: "Hanes",
  category: "Hoodies",
  tags: ["Cool", "New!", "Hoodie"],
  stock: 34,
);

CartItemModel cartItemModel = CartItemModel.fromItemModel(model: itemModelDemo, quantity: 2, dataChosen: {
  0: [1],
  1: [2, 1],
  2: [0, 1]
});

CartItemModel cartItemModel2 = CartItemModel.fromItemModel(model: itemModelDemo2, quantity: 1, dataChosen: {
  0: [2],
  1: [1, 0]
});

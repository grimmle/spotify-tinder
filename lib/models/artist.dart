class Artist {
  final String name;
  final String id;
  final String href;
  final String image;
  // final Image img;

  const Artist({
    required this.name,
    required this.id,
    required this.href,
    required this.image,
    // required this.img,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    if (json['images'] != null) {
      return Artist(
        name: json['name'] as String,
        id: json['id'] as String,
        href: json['href'] as String,
        image: json['images'][2]['url'] as String,
        // img: json['href'] as String,
      );
    }
    return Artist(
      name: json['name'] as String,
      id: json['id'] as String,
      href: json['href'] as String,
      image: '',
      // img: json['href'] as String,
    );
  }
}

part of flutter_mentions;

class OptionList extends StatelessWidget {
  OptionList({
    required this.data,
    required this.onTap,
    required this.suggestionListHeight,
    this.suggestionBuilder,
    this.suggestionListDecoration,
  });

  final Widget Function(Map<String, dynamic>)? suggestionBuilder;

  final List<Map<String, dynamic>> data;

  final Function(Map<String, dynamic>) onTap;

  final double suggestionListHeight;

  final BoxDecoration? suggestionListDecoration;

  @override
  Widget build(BuildContext context) 
  {
    return data.isNotEmpty
        ? Container(
          padding: EdgeInsets.only(left:28),
            decoration:
                suggestionListDecoration ?? BoxDecoration(color: Colors.white),
            constraints: BoxConstraints(
              maxHeight: suggestionListHeight,
              minHeight: 0,
            ),
            child: ListView.builder(
              itemCount: data.length,
              shrinkWrap: true,
              itemBuilder: (context, index) 
              {
                return InkWell(
                  onTap: () {
                    print("ontaaap");
                    onTap(data[index]);
                  },
                  child: suggestionBuilder == null
                      ? suggestionBuilder!(data[index])
                      : Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            data[index]['photo'],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(data[index]['full_name']),
                                            Text('@${data[index]['display']}'),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                        ,
                );
              },
            ),
          )
        : Container();
  }
}

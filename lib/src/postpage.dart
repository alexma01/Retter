import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutterreddit/src/postpage_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutterreddit/src/common/LaunchURL.dart';
import 'package:flutterreddit/src/common/PostIcon.dart';

class PostPage extends StatelessWidget {
  final PostPageViewModel viewModel;

  const PostPage({@required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(viewModel.submission.title)),
        body: ListView(
          children: <Widget>[
            _buildPost(context: context, submission: viewModel.submission),
            if (viewModel.isSelfPost())
              _buildSelfText(
                  context: context, submission: viewModel.submission),
            Divider(
              thickness: 2,
            ),
            viewModel.loadingComments
                ? _buildLoadingCommentsIndicator()
                : _buildComments(),
          ],
        ),
      );
    });
  }

  Widget _buildPost({BuildContext context, Submission submission}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: GestureDetector(
        onTap: () {
          if (!submission.isSelf) {
            launchURL(submission.url.toString());
          }
        },
        child: Card(
          color: Colors.black26,
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SubredditPost.buildPostIcon(submission),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(submission.title),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text(submission.upvotes.toString()),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildSelfText({BuildContext context, Submission submission}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Card(
        color: Colors.black26,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: MarkdownBody(
            data: submission.selftext,
            onTapLink: (String url) {
              launchURL(url);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComments() {
    return Observer(builder: (_) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: viewModel.comments.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildComment(viewModel.comments[index]);
        },
      );
    });
  }

  Widget _buildComment(PageComment comment) {
    return Card(
      margin: EdgeInsets.fromLTRB(5.0 * comment.commentLevel, 5.0, 5.0, 5.0),
      color: Colors.black26,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              comment.commentData.author,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            MarkdownBody(
              data: comment.commentData.body,
              onTapLink: (String url) {
                launchURL(url);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCommentsIndicator() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Loading comments...'),
          SizedBox(
            width: 10,
          ),
          CupertinoActivityIndicator(),
        ],
      ),
    );
  }
}

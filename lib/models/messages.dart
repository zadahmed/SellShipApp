class ChatMessages implements Comparable<ChatMessages> {
  final String messageid;
  final String peoplemessaged;
  final String senderid;
  final String recipentid;
  final String lastrecieved;
  final String recieveddate;
  final String hiddendate;
  final bool unread;

  ChatMessages(
      {this.messageid,
      this.peoplemessaged,
      this.senderid,
      this.recipentid,
      this.lastrecieved,
      this.hiddendate,
      this.recieveddate,
      this.unread});

  int compareTo(ChatMessages other) {
    int order = other.hiddendate.compareTo(hiddendate);
    return order;
  }
}

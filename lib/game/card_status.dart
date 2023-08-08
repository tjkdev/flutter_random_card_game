class CardStatus {

  CardStatus.myCardDefault();

  CardStatus.enemyCardDefault(this.value) {
    type = CardType.enemy;
    isClickable = false;
  }

  CardType type = CardType.me;
  int value = 0;
  bool isClickable = false;
  bool isSlideAnimationDone = false;
  bool isOpenAnimationDone = false;
  bool isRemoveAnimationDone = false;
}

enum CardType {
  me, enemy;
}
import 'package:flutter/material.dart';

/* 아임포트 결제 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_payment.dart';
/* 아임포트 결제 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/payment_data.dart';

class impart extends StatelessWidget {
  final int finalprice;
  final String name;
  final String phone;
  final String email;

  impart({
    required this.finalprice,
    required this.name,
    required this.phone,
    required this.email,
  });
  @override
  Widget build(BuildContext context) {
    print("결제중 $phone");
    return IamportPayment(
      appBar: new AppBar(
        title: new Text('아임포트 결제'),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/iamport-logo.png'),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20)),
            ],
          ),
        ), //imp62488455
      ),  //imp23488700
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp23488700',
      /* [필수입력] 결제 데이터 */
      data: PaymentData(
          pg: 'kakaopay',                                          // PG사
          payMethod: 'card',                                           // 결제수단
          merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
          name: '아임포트 결제데이터 분석',
          amount: finalprice,
          currency: 'KRW',// 결제금액
          language: "KO",
          buyerName: name,                                           // 구매자 이름
          buyerTel: phone,                                     // 구매자 연락처
          buyerEmail: email,                                // 구매자 우편번호
          appScheme: 'example',                                         //결제창 UI 내 할부개월수 제한
      ),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        print('결제 결과: $result');
        Navigator.pop(context, result);  // 이전 화면으로 결제 결과를 반환하면서 돌아감
      },
    );
  }
}
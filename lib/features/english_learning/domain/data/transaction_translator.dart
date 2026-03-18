import 'package:flutter/material.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';

class TransactionTranslator {
  TransactionTranslator._();

  static const _titleMap = <String, String>{
    // 식비
    '점심': 'lunch',
    '저녁': 'dinner',
    '아침': 'breakfast',
    '밥': 'a meal',
    '식사': 'a meal',
    '치킨': 'chicken',
    '피자': 'pizza',
    '햄버거': 'a hamburger',
    '국밥': 'rice soup',
    '김밥': 'gimbap',
    '라면': 'ramen',
    '배달': 'delivery food',
    '장보기': 'groceries',
    '반찬': 'side dishes',
    // 카페
    '스타벅스': 'Starbucks coffee',
    '커피': 'coffee',
    '카페': 'a cafe drink',
    '라떼': 'a latte',
    '아메리카노': 'an americano',
    '빵': 'bread',
    '케이크': 'cake',
    // 쇼핑
    '쇼핑': 'shopping',
    '옷': 'clothes',
    '신발': 'shoes',
    '가방': 'a bag',
    // 편의점
    '편의점': 'convenience store snacks',
    'CU': 'convenience store items',
    'GS25': 'convenience store items',
    // 교통
    '지하철': 'the subway',
    '버스': 'the bus',
    '택시': 'a taxi ride',
    '주유': 'gas',
    '교통': 'transportation',
    // 의료
    '병원': 'a hospital visit',
    '약국': 'medicine',
    '약': 'medicine',
    // 문화
    '영화': 'a movie',
    '넷플릭스': 'Netflix subscription',
    '책': 'a book',
    '게임': 'a game',
    // 뷰티
    '미용실': 'a haircut',
    '화장품': 'cosmetics',
    // 수입
    '급여': 'salary',
    '월급': 'salary',
    '용돈': 'allowance',
    '부업': 'a side job',
    '보너스': 'bonus',
    '이자': 'interest',
  };

  static final _iconFallback = <IconData, String>{
    Icons.fastfood: 'food',
    Icons.restaurant: 'a meal',
    Icons.local_cafe: 'coffee',
    Icons.shopping_bag: 'shopping',
    Icons.checkroom: 'clothes',
    Icons.local_convenience_store: 'convenience store items',
    Icons.directions_subway: 'the subway',
    Icons.directions_bus: 'the bus',
    Icons.local_taxi: 'a taxi ride',
    Icons.local_gas_station: 'gas',
    Icons.local_hospital: 'a hospital visit',
    Icons.medical_services: 'medicine',
    Icons.movie: 'a movie',
    Icons.menu_book: 'a book',
    Icons.content_cut: 'a haircut',
    Icons.face: 'cosmetics',
    Icons.account_balance_wallet: 'salary',
    Icons.card_giftcard: 'allowance',
    Icons.work: 'a side job',
  };

  static String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  static String _findEnglish(Transaction tx) {
    for (final entry in _titleMap.entries) {
      if (tx.title.contains(entry.key)) return entry.value;
    }
    final fallback = _iconFallback[tx.icon];
    if (fallback != null) return fallback;
    return tx.type == TransactionType.expense ? 'something' : 'other income';
  }

  static String translate(Transaction tx) {
    final item = _findEnglish(tx);
    final amount = '₩${_fmt(tx.amount)}';
    if (tx.type == TransactionType.expense) {
      return 'I spent $amount on $item.';
    } else {
      return 'I earned $amount from $item.';
    }
  }

  static String translateKorean(Transaction tx) {
    final amount = '${_fmt(tx.amount)}원';
    if (tx.type == TransactionType.expense) {
      return '${tx.title}에 $amount을 썼다.';
    } else {
      return '${tx.title}으로 $amount을 벌었다.';
    }
  }
}

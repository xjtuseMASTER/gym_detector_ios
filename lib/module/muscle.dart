//肌肉对象
import 'dart:ui';

class Muscle {
  final String name;//肌肉名称
  final String description;//肌肉描述
  final Offset position;//肌肉位置
  final int index;//肌肉编号

  Muscle({required this.name, required this.description, required this.position,required this.index});
  
  static List<Muscle> customMuscleList(){
    return [
    Muscle(name: 'Shoulder', description: '肩部肌肉描述', position: Offset(351,225), index: 1),
    Muscle(name: 'triceps', description: '肱三头肌描述', position: Offset(55,317), index: 2),
    Muscle(name: 'bicipital', description: '肱二头肌描述', position: Offset(359,329), index: 3),
    Muscle(name: 'chest', description: '胸大肌描述', position: Offset(177,276), index: 4),
    Muscle(name: 'back', description: '背肌描述', position: Offset(320,378), index: 5),
    Muscle(name: 'abdominal', description: '腹肌描述', position: Offset(200,421), index: 6),
    Muscle(name: 'quadriceps', description: '大腿外侧肌肉描述', position: Offset(331,620), index: 7),
    Muscle(name: 'Quad', description: '大腿内侧肌肉描述', position: Offset(191,689), index: 8),
    Muscle(name: 'calf', description: '小腿肌肉描述', position: Offset(271,851), index: 9),
  ];

  }
}

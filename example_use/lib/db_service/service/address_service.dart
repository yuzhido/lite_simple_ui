import 'package:dio/dio.dart';
import '../dao/address_dao.dart';
import '../model/address_node.dart';

/// 地址服务类 - 使用 Dio 封装数据库操作，提供统一的接口
///
/// 这个设计允许我们：
/// 1. 模拟 API 调用方式
/// 2. 统一错误处理
/// 3. 方便后续切换到远程 API
class AddressService {
  final AddressDao _dao = AddressDao();

  // Dio 实例（目前用于模拟本地操作，后续可扩展为远程 API）
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));

  /// 获取所有树形数据
  Future<Response<List<Map<String, dynamic>>>> getAllTreeData() async {
    try {
      // 从数据库获取完整的树形结构
      final treeData = await _dao.getTreeStructure();

      // 转换为 TreeSelect 组件需要的格式
      final result = treeData.map((node) => _convertToTreeFormat(node)).toList();

      return Response(
        data: result,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/address/tree'),
      );
    } catch (e) {
      return Response(
        data: [],
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address/tree'),
      );
    }
  }

  /// 根据 ID 获取单个地址
  Future<Response<Map<String, dynamic>?>> getById(String id) async {
    try {
      final node = await _dao.getById(id);
      if (node == null) {
        return Response(
          data: null,
          statusCode: 404,
          statusMessage: 'Address not found',
          requestOptions: RequestOptions(path: '/address/$id'),
        );
      }

      return Response(
        data: node.toMap(),
        statusCode: 200,
        requestOptions: RequestOptions(path: '/address/$id'),
      );
    } catch (e) {
      return Response(
        data: null,
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address/$id'),
      );
    }
  }

  /// 创建新地址
  Future<Response<Map<String, dynamic>>> create(Map<String, dynamic> data) async {
    try {
      final node = AddressNode.fromMap(data);
      await _dao.insert(node);

      return Response(
        data: node.toMap(),
        statusCode: 201,
        requestOptions: RequestOptions(path: '/address'),
      );
    } catch (e) {
      return Response(
        data: {},
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address'),
      );
    }
  }

  /// 更新地址
  Future<Response<Map<String, dynamic>>> update(String id, Map<String, dynamic> data) async {
    try {
      final node = AddressNode.fromMap(data);
      await _dao.update(id, node);

      return Response(
        data: node.toMap(),
        statusCode: 200,
        requestOptions: RequestOptions(path: '/address/$id'),
      );
    } catch (e) {
      return Response(
        data: {},
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address/$id'),
      );
    }
  }

  /// 删除地址
  Future<Response<void>> delete(String id) async {
    try {
      await _dao.delete(id);

      return Response(data: null, statusCode: 204, requestOptions: RequestOptions(path: '/address/$id'));
    } catch (e) {
      return Response(
        data: null,
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address/$id'),
      );
    }
  }

  /// 初始化测试数据
  Future<void> initTestData() async {
    try {
      // 先清空现有数据
      await _dao.clearAll();

      // 准备测试数据
      final testData = [
        // 北京市
        {'id': '1', 'name': '北京市', 'parent_id': null, 'level': 0},
        {'id': '1-1', 'name': '东城区', 'parent_id': '1', 'level': 1},
        {'id': '1-1-1', 'name': '东华门街道', 'parent_id': '1-1', 'level': 2},
        {'id': '1-1-2', 'name': '景山街道', 'parent_id': '1-1', 'level': 2},
        {'id': '1-2', 'name': '西城区', 'parent_id': '1', 'level': 1},
        {'id': '1-2-1', 'name': '西长安街街道', 'parent_id': '1-2', 'level': 2},
        {'id': '1-2-2', 'name': '新街口街道', 'parent_id': '1-2', 'level': 2},
        {'id': '1-3', 'name': '朝阳区', 'parent_id': '1', 'level': 1},
        {'id': '1-3-1', 'name': '朝外街道', 'parent_id': '1-3', 'level': 2},
        {'id': '1-3-2', 'name': '三里屯街道', 'parent_id': '1-3', 'level': 2},

        // 上海市
        {'id': '2', 'name': '上海市', 'parent_id': null, 'level': 0},
        {'id': '2-1', 'name': '黄浦区', 'parent_id': '2', 'level': 1},
        {'id': '2-1-1', 'name': '外滩街道', 'parent_id': '2-1', 'level': 2},
        {'id': '2-1-2', 'name': '南京东路街道', 'parent_id': '2-1', 'level': 2},
        {'id': '2-2', 'name': '浦东新区', 'parent_id': '2', 'level': 1},
        {'id': '2-2-1', 'name': '陆家嘴街道', 'parent_id': '2-2', 'level': 2},
        {'id': '2-2-2', 'name': '张江镇', 'parent_id': '2-2', 'level': 2},

        // 广东省
        {'id': '3', 'name': '广东省', 'parent_id': null, 'level': 0},
        {'id': '3-1', 'name': '广州市', 'parent_id': '3', 'level': 1},
        {'id': '3-1-1', 'name': '天河区', 'parent_id': '3-1', 'level': 2},
        {'id': '3-1-2', 'name': '越秀区', 'parent_id': '3-1', 'level': 2},
        {'id': '3-2', 'name': '深圳市', 'parent_id': '3', 'level': 1},
        {'id': '3-2-1', 'name': '南山区', 'parent_id': '3-2', 'level': 2},
        {'id': '3-2-2', 'name': '福田区', 'parent_id': '3-2', 'level': 2},
        {'id': '3-2-3', 'name': '罗湖区', 'parent_id': '3-2', 'level': 2},
      ];

      // 批量插入数据
      final nodes = testData.map((data) => AddressNode.fromMap(data)).toList();
      await _dao.insertAll(nodes);
    } catch (e) {
      throw Exception('初始化测试数据失败：$e');
    }
  }

  /// 将 AddressNode 转换为树形格式
  Map<String, dynamic> _convertToTreeFormat(AddressNode node) {
    final result = <String, dynamic>{'id': node.id, 'name': node.name};

    // 如果有子节点数据
    if (node.children != null && node.children!['items'] != null) {
      final childrenList = node.children!['items'] as List;
      result['children'] = childrenList.whereType<Map<String, dynamic>>().map((child) => _convertToTreeFormat(AddressNode.fromMap(child))).toList();
    }

    return result;
  }

  /// 根据关键字搜索地址（远程搜索使用）
  Future<Response<List<Map<String, dynamic>>>> searchByKeyword(String keyword) async {
    try {
      // 获取所有节点
      final allNodes = await _dao.getAll();

      // 模糊查询匹配名称包含关键字的节点
      final matched = allNodes.where((node) => node.name.toLowerCase().contains(keyword.toLowerCase())).map((node) => node.toMap()).toList();

      return Response(
        data: matched,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/address/search'),
      );
    } catch (e) {
      return Response(
        data: [],
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address/search'),
      );
    }
  }

  /// 获取指定节点及其子节点（懒加载使用）
  Future<Response<List<Map<String, dynamic>>>> getNodeWithChildren(String nodeId) async {
    try {
      final node = await _dao.getById(nodeId);
      if (node == null) {
        return Response(
          data: [],
          statusCode: 404,
          statusMessage: 'Node not found',
          requestOptions: RequestOptions(path: '/address/$nodeId'),
        );
      }

      // 获取子节点
      final children = await _dao.getChildren(nodeId);

      // 构建树形结构
      final result = <Map<String, dynamic>>[];
      final nodeMap = node.toMap();

      if (children.isNotEmpty) {
        nodeMap['children'] = children.map((c) => c.toMap()).toList();
      }

      result.add(nodeMap);

      return Response(
        data: result,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/address/$nodeId'),
      );
    } catch (e) {
      return Response(
        data: [],
        statusCode: 500,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(path: '/address/$nodeId'),
      );
    }
  }

  /// 关闭数据库连接
  void dispose() {
    _dio.close();
  }
}

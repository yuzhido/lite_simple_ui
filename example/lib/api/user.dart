import '../core/network/index.dart';

/// 用户模型
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? password; // 仅用于创建/更新，查询时通常不返回
  final String role;
  final String? avatar;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({required this.id, required this.username, required this.email, this.password, this.role = 'user', this.avatar, this.isActive = true, this.createdAt, this.updatedAt});

  /// 从 JSON 创建 UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      isActive: json['isActive'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'username': username, 'email': email, 'role': role, 'avatar': avatar, 'isActive': isActive};
    if (password != null) {
      data['password'] = password;
    }
    return data;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, role: $role)';
  }
}

/// 分页数据模型
class PageData<T> {
  final List<T> list;
  final int total;
  final int page;
  final int limit;
  final int pages;

  PageData({required this.list, required this.total, required this.page, required this.limit, required this.pages});

  /// 从 JSON 创建 PageData
  factory PageData.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final pagination = json['pagination'] ?? {};
    final listData = json['list'] as List<dynamic>? ?? [];

    return PageData<T>(
      list: listData.map((item) => fromJson(item as Map<String, dynamic>)).toList(),
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 10,
      pages: pagination['pages'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PageData(total: $total, page: $page, limit: $limit, pages: $pages, list.length: ${list.length})';
  }
}

/// 用户 API 服务类
class UserApi {
  static final HttpClient _httpClient = HttpClient.getInstance();

  /// 获取用户列表（分页）
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 10
  /// [keyword] 关键字搜索（用户名或邮箱）
  /// [role] 按角色筛选
  /// [isActive] 按激活状态筛选
  ///
  /// 返回分页数据
  static Future<PageData<UserModel>> getPage({int page = 1, int limit = 10, String? keyword, String? role, bool? isActive}) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (keyword != null && keyword.isNotEmpty) {
      queryParameters['keyword'] = keyword;
    }
    if (role != null && role.isNotEmpty) {
      queryParameters['role'] = role;
    }
    if (isActive != null) {
      queryParameters['isActive'] = isActive;
    }

    final response = await _httpClient.get<Map<String, dynamic>>('/users', queryParameters: queryParameters);

    return PageData<UserModel>.fromJson(response, (json) => UserModel.fromJson(json));
  }

  /// 获取用户详情
  ///
  /// [id] 用户 ID
  ///
  /// 返回用户模型
  static Future<UserModel> getUser(String id) async {
    final response = await _httpClient.get<Map<String, dynamic>>('/users/$id');
    return UserModel.fromJson(response);
  }

  /// 创建用户
  ///
  /// [username] 用户名（必填）
  /// [email] 邮箱（必填）
  /// [password] 密码（必填，至少6位）
  /// [role] 角色，默认 'user'
  /// [avatar] 头像 URL
  /// [isActive] 是否激活，默认 true
  ///
  /// 返回创建的用户模型
  static Future<UserModel> add({required String username, required String email, required String password, String role = 'user', String? avatar, bool isActive = true}) async {
    final user = UserModel(
      id: '', // ID 由后端生成
      username: username,
      email: email,
      password: password,
      role: role,
      avatar: avatar,
      isActive: isActive,
    );

    final response = await _httpClient.post<Map<String, dynamic>>('/users', data: user.toJson());

    return UserModel.fromJson(response);
  }

  /// 更新用户
  ///
  /// [id] 用户 ID
  /// [username] 用户名
  /// [email] 邮箱
  /// [password] 密码（可选）
  /// [role] 角色
  /// [avatar] 头像 URL
  /// [isActive] 是否激活
  ///
  /// 返回更新后的用户模型
  static Future<UserModel> update({required String id, String? username, String? email, String? password, String? role, String? avatar, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    if (avatar != null) data['avatar'] = avatar;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _httpClient.put<Map<String, dynamic>>('/users/$id', data: data);

    return UserModel.fromJson(response);
  }

  /// 删除用户
  ///
  /// [id] 用户 ID
  ///
  /// 返回是否成功
  static Future<bool> delete(String id) async {
    await _httpClient.delete('/users/$id');
    return true;
  }

  /// 搜索用户（快捷方法）
  ///
  /// [keyword] 搜索关键字
  /// [page] 页码
  /// [limit] 每页数量
  ///
  /// 返回分页数据
  static Future<PageData<UserModel>> search({required String keyword, int page = 1, int limit = 10}) {
    return getPage(page: page, limit: limit, keyword: keyword);
  }

  /// 按角色获取用户
  ///
  /// [role] 角色
  /// [page] 页码
  /// [limit] 每页数量
  ///
  /// 返回分页数据
  static Future<PageData<UserModel>> getByRole({required String role, int page = 1, int limit = 10}) {
    return getPage(page: page, limit: limit, role: role);
  }

  /// 获取激活的用户
  ///
  /// [page] 页码
  /// [limit] 每页数量
  ///
  /// 返回分页数据
  static Future<PageData<UserModel>> getActiveUsers({int page = 1, int limit = 10}) {
    return getPage(page: page, limit: limit, isActive: true);
  }
}

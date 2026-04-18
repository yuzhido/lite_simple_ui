const swaggerJsdoc = require('swagger-jsdoc');
const fs = require('fs');
const path = require('path');
const { DataTypes } = require('sequelize');

/**
 * 将 Sequelize 数据类型映射到 Swagger 类型
 */
function mapSequelizeTypeToSwagger(typeInstance, typeName) {
  if (!typeInstance) return { type: 'string' };

  const typeStr = typeName || typeInstance.toString();

  if (typeStr.includes('INTEGER') || typeStr.includes('INT')) {
    return { type: 'integer' };
  }
  if (typeStr.includes('BIGINT')) {
    return { type: 'integer', format: 'int64' };
  }
  if (typeStr.includes('FLOAT') || typeStr.includes('DOUBLE') || typeStr.includes('DECIMAL')) {
    return { type: 'number', format: 'float' };
  }
  if (typeStr.includes('BOOLEAN') || typeStr.includes('BOOL')) {
    return { type: 'boolean' };
  }
  if (typeStr.includes('DATEONLY')) {
    return { type: 'string', format: 'date' };
  }
  if (typeStr.includes('DATE') || typeStr.includes('TIME')) {
    return { type: 'string', format: 'date-time' };
  }
  if (typeStr.includes('TEXT')) {
    return { type: 'string' };
  }
  if (typeStr.includes('JSON')) {
    return { type: 'object' };
  }
  // 默认字符串类型
  if (typeStr.includes('STRING')) {
    const match = typeStr.match(/\((\d+)\)/);
    const maxLength = match ? parseInt(match[1]) : undefined;
    return maxLength ? { type: 'string', maxLength } : { type: 'string' };
  }

  return { type: 'string' };
}

/**
 * 从 Sequelize 模型生成 Swagger Schema
 */
function generateSchemaFromModel(model) {
  if (!model || !model.rawAttributes) return null;

  const schemaName = model.name;
  const attributes = model.rawAttributes;
  const options = model.options || {};

  const schema = {
    type: 'object',
    required: [],
    properties: {}
  };

  // 处理每个字段
  for (const [fieldName, fieldConfig] of Object.entries(attributes)) {
    // 跳过 Sequelize 自动管理的时间戳字段
    const timestampFields = ['createdAt', 'updatedAt', 'created_at', 'updated_at', 'create_time', 'modify_time'];
    if (timestampFields.includes(fieldName)) {
      continue;
    }

    // 映射字段名（下划线转驼峰，用于 Swagger）
    const swaggerFieldName = fieldName.replace(/_([a-z])/g, (g) => g[1].toUpperCase());

    // 映射类型
    let fieldSchema = mapSequelizeTypeToSwagger(fieldConfig.type, fieldConfig.typeName || fieldConfig.type?.toString());

    // 处理 ENUM 类型
    if (fieldConfig.type instanceof DataTypes.ENUM || fieldConfig.type?.toString().includes('ENUM')) {
      const typeStr = fieldConfig.type.toString();
      const enumMatch = typeStr.match(/ENUM\(([^)]+)\)/);
      if (enumMatch) {
        const values = enumMatch[1].split(',').map((v) => v.trim().replace(/['"]/g, ''));
        fieldSchema = {
          type: 'string',
          enum: values
        };
      }
    }

    // 设置字段描述
    if (fieldConfig.comment) {
      fieldSchema.description = fieldConfig.comment;
    }

    // 设置默认值（排除函数默认值）
    if (fieldConfig.defaultValue !== undefined && fieldConfig.defaultValue !== null && typeof fieldConfig.defaultValue !== 'function') {
      fieldSchema.default = fieldConfig.defaultValue;
    } else if (typeof fieldConfig.defaultValue === 'function') {
      fieldSchema.description = (fieldSchema.description || '') + '（自动生成）';
    }

    // 设置是否允许为空
    if (fieldConfig.allowNull === false && !fieldConfig.defaultValue) {
      schema.required.push(swaggerFieldName);
    }

    schema.properties[swaggerFieldName] = fieldSchema;
  }

  // 自动添加时间戳字段
  if (options.timestamps !== false) {
    const createdAtField = options.createdAt === true ? 'createdAt' : options.createdAt || 'createdAt';
    const updatedAtField = options.updatedAt === true ? 'updatedAt' : options.updatedAt || 'updatedAt';

    if (createdAtField && !schema.properties[createdAtField]) {
      schema.properties[createdAtField] = {
        type: 'string',
        format: 'date-time',
        description: '创建时间'
      };
    }
    if (updatedAtField && !schema.properties[updatedAtField]) {
      schema.properties[updatedAtField] = {
        type: 'string',
        format: 'date-time',
        description: '更新时间'
      };
    }
  }

  return { schemaName, schema };
}

/**
 * 生成示例数据
 */
function generateExample(schema) {
  const example = {};

  for (const [fieldName, fieldConfig] of Object.entries(schema.properties)) {
    if (fieldConfig.enum) {
      example[fieldName] = fieldConfig.enum[0];
    } else if (fieldConfig.type === 'string') {
      if (fieldName === 'id') {
        example[fieldName] = '2738192837465738';
      } else if (fieldName.toLowerCase().includes('email')) {
        example[fieldName] = 'example@email.com';
      } else if (fieldName.toLowerCase().includes('url') || fieldName.toLowerCase().includes('avatar')) {
        example[fieldName] = 'https://example.com/image.jpg';
      } else {
        example[fieldName] = fieldConfig.description || '示例文本';
      }
    } else if (fieldConfig.type === 'integer' || fieldConfig.type === 'number') {
      example[fieldName] = fieldConfig.default !== undefined ? fieldConfig.default : 0;
    } else if (fieldConfig.type === 'boolean') {
      example[fieldName] = fieldConfig.default !== undefined ? fieldConfig.default : true;
    } else if (fieldConfig.type === 'object') {
      example[fieldName] = {};
    }
  }

  return example;
}

/**
 * 自动从 modules 目录加载所有模型并生成 Schema
 */
function autoGenerateSchemasFromModels() {
  const schemas = {};
  const modulesDir = path.join(__dirname, '..', 'modules');

  if (!fs.existsSync(modulesDir)) {
    return schemas;
  }

  const modules = fs.readdirSync(modulesDir, { withFileTypes: true });

  modules.forEach((module) => {
    if (module.isDirectory()) {
      const modelPath = path.join(modulesDir, module.name, 'model.js');

      if (fs.existsSync(modelPath)) {
        try {
          // 清除缓存以确保获取最新的模型定义
          delete require.cache[require.resolve(modelPath)];
          const model = require(modelPath);

          if (model && model.rawAttributes) {
            const { schemaName, schema } = generateSchemaFromModel(model);
            schema.example = generateExample(schema);
            schemas[schemaName] = schema;
            console.log(`✅ Auto-generated Swagger schema for: ${schemaName}`);
          }
        } catch (error) {
          console.error(`❌ Failed to generate schema for module ${module.name}:`, error.message);
        }
      }
    }
  });

  return schemas;
}

// 自动生成所有模型的 Schema
const autoGeneratedSchemas = autoGenerateSchemasFromModels();

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: '模拟数据服务器 API',
      version: '1.0.0',
      description: '基于 Express 和 Sequelize 的模拟数据服务器 API 文档\n\n📄 [查看 Swagger JSON 原始数据](/api-docs/swagger.json)'
      // contact: {
      //   name: 'API Support',
      //   email: 'support@example.com'
      // }
      // license: {
      //   name: 'ISC',
      //   url: 'https://opensource.org/licenses/ISC'
      // }
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: '本地开发服务器'
      }
    ],
    components: {
      schemas: {
        // 合并自动生成的 Schema 和手动定义的 Schema
        ...autoGeneratedSchemas,
        // 手动定义的通用 Schema
        ErrorResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: false
            },
            error: {
              type: 'string',
              example: 'Error message'
            }
          }
        },
        SuccessResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: true
            },
            data: {
              type: 'object'
            }
          }
        }
      }
    }
  },
  // 只扫描 API 路由文档（不再扫描 model.js，因为 Schema 已自动生成）
  apis: ['./modules/*/index.js', './modules/*/controller.js']
};

const specs = swaggerJsdoc(options);

/**
 * 自动从路由和控制器生成 API 文档
 */
function autoGenerateApiDocs(specs) {
  const fs = require('fs');
  const path = require('path');
  const modulesDir = path.join(__dirname, '..', 'modules');

  if (!fs.existsSync(modulesDir)) return specs;

  // 命名约定映射：函数名 -> API 描述
  const actionMap = {
    getAll: { method: 'GET', summary: '获取所有{name}', desc: '支持分页查询和筛选' },
    getTree: { method: 'GET', summary: '获取{name}树形结构', desc: '返回树形结构的{name}列表', path: '/tree' },
    getById: { method: 'GET', summary: '获取{name}详情', desc: '根据 ID 获取单个{name}详情', path: '/{id}' },
    create: { method: 'POST', summary: '创建新{name}', desc: '创建一个新的{name}记录' },
    update: { method: 'PUT', summary: '更新{name}信息', desc: '根据 ID 更新{name}', path: '/{id}' },
    remove: { method: 'DELETE', summary: '删除{name}', desc: '根据 ID 删除{name}', path: '/{id}' },
    delete: { method: 'DELETE', summary: '删除{name}', desc: '根据 ID 删除{name}', path: '/{id}' },
    getChildren: { method: 'GET', summary: '获取子{name}列表', desc: '获取指定{name}的所有子{name}', path: '/{id}/children' }
  };

  // 模块名称映射（英文 -> 中文）
  const moduleNames = {
    user: '用户',
    users: '用户',
    area: '区域',
    areas: '区域',
    product: '产品',
    order: '订单',
    category: '分类'
  };

  const modules = fs.readdirSync(modulesDir, { withFileTypes: true });

  modules.forEach((module) => {
    if (!module.isDirectory()) return;

    const moduleName = module.name;
    const modulePath = path.join(modulesDir, moduleName);
    const indexPath = path.join(modulePath, 'index.js');
    const controllerPath = path.join(modulePath, 'controller.js');

    if (!fs.existsSync(indexPath) || !fs.existsSync(controllerPath)) return;

    // 获取中文名称
    const cnName = moduleNames[moduleName.toLowerCase()] || moduleName;

    // 解析路由文件，提取路由定义
    try {
      const indexContent = fs.readFileSync(indexPath, 'utf-8');
      const controllerContent = fs.readFileSync(controllerPath, 'utf-8');

      // 提取导入的控制器函数
      const importMatch = indexContent.match(/require\(['"]\.\/controller['"]\)/);
      if (!importMatch) return;

      // 提取所有路由定义
      const routeMatches = indexContent.matchAll(/router\.(get|post|put|delete|patch)\(['"]([^'"]+)['"],\s*(\w+)\)/g);

      for (const match of routeMatches) {
        const method = match[1].toUpperCase();
        const routePath = match[2];
        const functionName = match[3];

        // 从 actionMap 获取 API 信息
        const action = actionMap[functionName];
        if (!action) continue;

        // 构建完整的 API 路径
        const fullPath = `/api/${moduleName}${routePath === '/' ? '' : routePath}`;

        // 生成 Swagger 路由定义
        const swaggerPath = fullPath.replace(/\/:([^/]+)/g, '/{$1}');

        const apiDoc = {
          [action.method.toLowerCase()]: {
            summary: action.summary.replace(/{name}/g, cnName),
            description: action.desc.replace(/{name}/g, cnName),
            tags: [moduleName.charAt(0).toUpperCase() + moduleName.slice(1)],
            responses: {
              200: {
                description: '成功',
                content: {
                  'application/json': {
                    schema: {
                      type: 'object',
                      properties: {
                        success: { type: 'boolean' },
                        data: {
                          $ref: `#/components/schemas/${moduleName.charAt(0).toUpperCase() + moduleName.slice(1)}`
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        };

        // POST 请求添加 requestBody
        if (action.method === 'POST') {
          apiDoc[action.method.toLowerCase()].requestBody = {
            required: true,
            content: {
              'application/json': {
                schema: {
                  $ref: `#/components/schemas/${moduleName.charAt(0).toUpperCase() + moduleName.slice(1)}`
                }
              }
            }
          };
          apiDoc[action.method.toLowerCase()].responses['201'] = apiDoc[action.method.toLowerCase()].responses['200'];
          delete apiDoc[action.method.toLowerCase()].responses['200'];
        }

        // 添加 path 参数（如果有 :id）
        if (routePath.includes(':id')) {
          apiDoc[action.method.toLowerCase()].parameters = [
            {
              in: 'path',
              name: 'id',
              required: true,
              schema: { type: 'string' },
              description: `${cnName} ID`
            }
          ];
        }

        // 添加到 specs
        if (!specs.paths) specs.paths = {};
        if (!specs.paths[swaggerPath]) specs.paths[swaggerPath] = {};
        specs.paths[swaggerPath] = {
          ...specs.paths[swaggerPath],
          ...apiDoc
        };
      }

      console.log(`✅ Auto-generated API docs for: ${moduleName} (${cnName})`);
    } catch (error) {
      console.error(`❌ Failed to generate API docs for ${moduleName}:`, error.message);
    }
  });

  return specs;
}

// 自动生成 API 文档
const finalSpecs = autoGenerateApiDocs(specs);

module.exports = finalSpecs;

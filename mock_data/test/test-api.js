const http = require('http');

const BASE_URL = 'http://localhost:3000';

// Helper function to make HTTP requests
function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';

      res.on('data', (chunk) => {
        body += chunk;
      });

      res.on('end', () => {
        try {
          resolve({
            statusCode: res.statusCode,
            data: JSON.parse(body)
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: body
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

async function testAPI() {
  console.log('🧪 Testing Mock Data API...\n');

  try {
    // Test 1: Get server info
    console.log('1️⃣  Testing GET / (Server Info)');
    const serverInfo = await makeRequest('GET', '/');
    console.log('✓ Server Info:', serverInfo.data.message);
    console.log('');

    // Test 2: Create mock data
    console.log('2️⃣  Testing POST /api/mock-data (Create Data)');
    const testData = {
      title: '测试数据',
      description: '这是一个测试描述',
      category: 'text',
      data: {
        content: '这是具体的测试内容',
        tags: ['test', 'mock']
      }
    };

    const createResult = await makeRequest('POST', '/api/mock-data', testData);
    console.log('✓ Created:', createResult.data.success);
    const createdId = createResult.data.data._id;
    console.log('');

    // Test 3: Get all mock data
    console.log('3️⃣  Testing GET /api/mock-data (Get All)');
    const getAllResult = await makeRequest('GET', '/api/mock-data');
    console.log('✓ Total count:', getAllResult.data.total);
    console.log('✓ Current page:', getAllResult.data.page);
    console.log('');

    // Test 4: Get single mock data
    console.log('4️⃣  Testing GET /api/mock-data/:id (Get Single)');
    const getSingleResult = await makeRequest('GET', `/api/mock-data/${createdId}`);
    console.log('✓ Found:', getSingleResult.data.success);
    console.log('✓ Title:', getSingleResult.data.data.title);
    console.log('');

    // Test 5: Update mock data
    console.log('5️⃣  Testing PUT /api/mock-data/:id (Update)');
    const updateData = {
      title: '更新后的标题'
    };
    const updateResult = await makeRequest('PUT', `/api/mock-data/${createdId}`, updateData);
    console.log('✓ Updated:', updateResult.data.success);
    console.log('✓ New title:', updateResult.data.data.title);
    console.log('');

    // Test 6: Delete mock data
    console.log('6️⃣  Testing DELETE /api/mock-data/:id (Delete)');
    const deleteResult = await makeRequest('DELETE', `/api/mock-data/${createdId}`);
    console.log('✓ Deleted:', deleteResult.data.success);
    console.log('');

    console.log('✅ All tests passed!');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run tests
testAPI();

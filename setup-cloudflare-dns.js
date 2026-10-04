const fs = require('fs');
const path = require('path');

const tomlPath = path.join(process.env.APPDATA, 'xdg.config', '.wrangler', 'config', 'default.toml');

async function getValidToken() {
  if (!fs.existsSync(tomlPath)) return null;
  const content = fs.readFileSync(tomlPath, 'utf8');
  const m = content.match(/oauth_token\s*=\s*\"([^\"]+)\"/);
  if (!m) return null;
  const token = m[1];
  
  // Test token
  const res = await fetch('https://api.cloudflare.com/client/v4/user', {
    headers: { Authorization: 'Bearer ' + token }
  });
  const data = await res.json();
  if (data.success) {
    return token;
  }
  return null;
}

async function configureDns(token) {
  console.log('[1/3] 正在查询 11s.space 的 Zone ID...');
  const zRes = await fetch('https://api.cloudflare.com/client/v4/zones?name=11s.space', {
    headers: { Authorization: 'Bearer ' + token }
  });
  const zData = await zRes.json();
  if (!zData.success || !zData.result.length) {
    console.error('获取 Zone 失败:', zData.errors);
    return false;
  }
  const zoneId = zData.result[0].id;
  console.log('获取到 Zone ID:', zoneId);

  console.log('[2/3] 检查是否已存在 nnu.11s.space 记录...');
  const recRes = await fetch(`https://api.cloudflare.com/client/v4/zones/${zoneId}/dns_records?name=nnu.11s.space`, {
    headers: { Authorization: 'Bearer ' + token }
  });
  const recData = await recRes.json();

  let ok = false;
  if (recData.success && recData.result.length > 0) {
    const existing = recData.result[0];
    console.log('[3/3] 更新现有 DNS 记录 ID:', existing.id);
    const updateRes = await fetch(`https://api.cloudflare.com/client/v4/zones/${zoneId}/dns_records/${existing.id}`, {
      method: 'PUT',
      headers: {
        Authorization: 'Bearer ' + token,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        type: 'CNAME',
        name: 'nnu',
        content: 'cname.vercel-dns.com',
        ttl: 1,
        proxied: false
      })
    });
    const upData = await updateRes.json();
    console.log('DNS 更新结果:', upData.success ? '成功！' : upData.errors);
    ok = upData.success;
  } else {
    console.log('[3/3] 创建全新 CNAME 记录...');
    const createRes = await fetch(`https://api.cloudflare.com/client/v4/zones/${zoneId}/dns_records`, {
      method: 'POST',
      headers: {
        Authorization: 'Bearer ' + token,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        type: 'CNAME',
        name: 'nnu',
        content: 'cname.vercel-dns.com',
        ttl: 1,
        proxied: false
      })
    });
    const crData = await createRes.json();
    console.log('DNS 创建结果:', crData.success ? '成功！' : crData.errors);
    ok = crData.success;
  }
  return ok;
}

async function main() {
  const token = await getValidToken();
  if (token) {
    console.log('已检测到有效 Cloudflare Token，开始自动配置 DNS...');
    const ok = await configureDns(token);
    if (ok) {
      console.log('🎉 DNS 配置完全成功！');
      process.exit(0);
    }
  } else {
    console.log('未检测到有效 Cloudflare 授权，需要唤起登录授权...');
    process.exit(1);
  }
}

main();

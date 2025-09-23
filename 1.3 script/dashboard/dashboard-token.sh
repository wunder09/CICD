#!/bin/bash
echo "=== Kubernetes Dashboard 访问信息 ==="
NODE_IP=$(hostname -I | awk '{print $1}')
NODE_PORT=$(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

if [ -z "$NODE_PORT" ]; then
    echo "❌ Dashboard服务未找到，请先安装Dashboard"
    exit 1
fi

echo ""
echo "🌐 访问地址: https://${NODE_IP}:${NODE_PORT}"
echo ""
echo "🔑 管理员Token:"
kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null || echo "❌ 无法获取Token，请检查admin-user是否存在"
echo ""
echo "📋 使用说明:"
echo "1. 在浏览器中访问上述地址"
echo "2. 忽略SSL证书警告"
echo "3. 选择'令牌'登录方式"
echo "4. 复制上面的Token并粘贴"
echo "5. 点击'登录'"
echo ""
echo "🔄 其他有用命令:"
echo "  查看Pod状态: kubectl get pods -n kubernetes-dashboard"
echo "  重启Dashboard: kubectl rollout restart deployment kubernetes-dashboard -n kubernetes-dashboard"

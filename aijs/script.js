document.addEventListener('DOMContentLoaded', function () {
    const guaDisplay = document.getElementById('gua-display');
    const suanButton = document.getElementById('suan');

    // 模拟加载数据（这里可以换成真实的AJAX请求）
    let gualist = {}; // 假设这是从服务器获取的数据

    // 加载卦象数据
    function loadGuaData() {
        fetch('gua.txt') // 确保你的服务器能正确响应这个路径
            .then(response => response.text())
            .then(text => {
                const lines = text.split('\n');
                for (let i = 0; i < 64 * 11; i += 11) {
                    const entry = {
                        Title: lines[i],
                        Type: lines[i + 1],
                        Xiangyue: lines[i + 2],
                        Intro: lines[i + 3],
                        Career: lines[i + 4],
                        Business: lines[i + 5],
                        Fame: lines[i + 6],
                        Travel: lines[i + 7],
                        Marriage: lines[i + 8],
                        Decision: lines[i + 9]
                    };
                    gualist[lines[i + 10]] = entry;
                }
            });
    }

    // 随机生成卦象
    function generateGua() {
        return Array.from({ length: 6 }, () => Math.round(Math.random())).join('');
    }

    // 显示卦象结果
    function showGuaResult(gua) {
        if (!gualist[gua]) {
            console.error('未找到对应的卦象信息');
            return;
        }

        const temp = gualist[gua];
        const resultDiv = document.createElement('div');
        resultDiv.innerHTML = `
            <h2>${temp.Title}</h2>
            <p><strong>类型:</strong> ${temp.Type}</p>
            <p><strong>象曰:</strong> ${temp.Xiangyue}</p>
            <p><strong>简介:</strong> ${temp.Intro}</p>
            <p><strong>事业:</strong> ${temp.Career}</p>
            <p><strong>商业:</strong> ${temp.Business}</p>
            <p><strong>名声:</strong> ${temp.Fame}</p>
            <p><strong>旅行:</strong> ${temp.Travel}</p>
            <p><strong>婚姻:</strong> ${temp.Marriage}</p>
            <p><strong>决策:</strong> ${temp.Decision}</p>
        `;
        guaDisplay.innerHTML = ''; // 清空之前的显示
        guaDisplay.appendChild(resultDiv);

        // 绘制卦象图形
        drawGua(gua);
    }

    // 绘制卦象图形
    function drawGua(gua) {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = 120;
        canvas.height = 180;

        const yaoWidth = 100;
        const yaoHeight = 20;
        const padding = 10;

        for (let i = 0; i < gua.length; i++) {
            const y = i * (yaoHeight + padding) + padding;
            ctx.fillStyle = 'black';
            if (gua[i] === '0') { // 断开的爻
                ctx.fillRect(padding, y, yaoWidth / 2 - padding, yaoHeight);
                ctx.fillRect(60 + padding, y, yaoWidth / 2 - padding, yaoHeight);
            } else { // 连续的爻
                ctx.fillRect(padding, y, yaoWidth, yaoHeight);
            }
        }

        guaDisplay.insertBefore(canvas, guaDisplay.firstChild);
    }

    // 初始化函数
    function init() {
        loadGuaData();

        suanButton.addEventListener('click', () => {
            const gua = generateGua();
            showGuaResult(gua);
        });
    }

    init();
});
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// カスタムトーストメッセージを表示する関数
function showToast(message, type = 'success') {
  // 既存のトーストがあれば削除
  const existingToast = document.querySelector('.custom-toast');
  if (existingToast) {
    existingToast.remove();
  }

  // トースト要素を作成
  const toast = document.createElement('div');
  toast.className = `custom-toast ${type}`;
  toast.textContent = message;
  
  // bodyに追加
  document.body.appendChild(toast);
  
  // フェードイン
  setTimeout(() => {
    toast.classList.add('show');
  }, 10);
  
  // 2秒後にフェードアウトして削除
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => {
      toast.remove();
    }, 300);
  }, 2000);
}

// クリップボードにコピーする関数
window.copyText = function(button) {
  const text = button.dataset.text;
  
  navigator.clipboard.writeText(text).then(() => {
    const originalText = button.textContent;
    button.textContent = 'コピーしました！';
    button.classList.add('copied');
    
    setTimeout(() => {
      button.textContent = originalText;
      button.classList.remove('copied');
    }, 2000);
  }).catch(err => {
    showToast('コピーに失敗しました', 'error');
    console.error('Failed to copy:', err);
  });
};

window.copyEmptyString = function() {
  navigator.clipboard.writeText('').then(() => {
    showToast('空文字をコピーしました');
  }).catch(err => {
    showToast('コピーに失敗しました', 'error');
  });
};

window.copyHalfWidthSpace = function() {
  navigator.clipboard.writeText(' ').then(() => {
    showToast('半角スペースをコピーしました');
  }).catch(err => {
    showToast('コピーに失敗しました', 'error');
  });
};

window.copyFullWidthSpace = function() {
  navigator.clipboard.writeText('　').then(() => {
    showToast('全角スペースをコピーしました');
  }).catch(err => {
    showToast('コピーに失敗しました', 'error');
  });
};

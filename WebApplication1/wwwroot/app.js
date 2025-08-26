class BlogApp {
    constructor() {
        this.currentView = 'list';
        this.posts = [];
        this.initializeEventListeners();
        this.loadPosts();
    }

    initializeEventListeners() {
        // Navigation buttons
        document.getElementById('new-post-btn').addEventListener('click', () => this.showCreateForm());
        document.getElementById('cancel-btn').addEventListener('click', () => this.showPostsList());
        document.getElementById('back-to-list-btn').addEventListener('click', () => this.showPostsList());
        
        // Form submission
        document.getElementById('post-form').addEventListener('submit', (e) => this.handleFormSubmit(e));
    }

    async loadPosts() {
        try {
            this.showLoading();
            const response = await fetch('/api/posts');
            if (!response.ok) throw new Error('Failed to load posts');
            
            this.posts = await response.json();
            this.renderPosts();
        } catch (error) {
            this.showError('Failed to load posts: ' + error.message);
        }
    }

    renderPosts() {
        const container = document.getElementById('posts-list');
        
        if (this.posts.length === 0) {
            container.innerHTML = '<p class="loading">No blog posts found. Create your first post!</p>';
            return;
        }

        const postsHtml = this.posts.map(post => `
            <div class="post-card">
                <div class="post-header">
                    <div>
                        <h2 class="post-title" onclick="blogApp.showPostDetail(${post.id})">${this.escapeHtml(post.title)}</h2>
                        <div class="post-meta">
                            By ${this.escapeHtml(post.author)} on ${this.formatDate(post.createdDate)}
                            ${post.updatedDate ? `(Updated: ${this.formatDate(post.updatedDate)})` : ''}
                        </div>
                    </div>
                    <div class="post-actions">
                        <button class="btn btn-primary btn-small" onclick="blogApp.editPost(${post.id})">Edit</button>
                        <button class="btn btn-danger btn-small" onclick="blogApp.deletePost(${post.id})">Delete</button>
                    </div>
                </div>
                ${post.summary ? `<p class="post-summary">${this.escapeHtml(post.summary)}</p>` : ''}
            </div>
        `).join('');

        container.innerHTML = postsHtml;
    }

    showCreateForm() {
        this.resetForm();
        document.getElementById('form-title').textContent = 'Create New Post';
        this.showView('form');
    }

    async editPost(id) {
        const post = this.posts.find(p => p.id === id);
        if (!post) return;

        document.getElementById('post-id').value = post.id;
        document.getElementById('title').value = post.title;
        document.getElementById('author').value = post.author;
        document.getElementById('summary').value = post.summary || '';
        document.getElementById('content').value = post.content;
        document.getElementById('is-published').checked = post.isPublished;
        
        document.getElementById('form-title').textContent = 'Edit Post';
        this.showView('form');
    }

    async deletePost(id) {
        if (!confirm('Are you sure you want to delete this post?')) return;

        try {
            const response = await fetch(`/api/posts/${id}`, {
                method: 'DELETE'
            });

            if (response.ok) {
                await this.loadPosts();
                this.showSuccess('Post deleted successfully!');
            } else {
                throw new Error('Failed to delete post');
            }
        } catch (error) {
            this.showError('Failed to delete post: ' + error.message);
        }
    }

    async showPostDetail(id) {
        try {
            const response = await fetch(`/api/posts/${id}`);
            if (!response.ok) throw new Error('Post not found');
            
            const post = await response.json();
            
            const detailHtml = `
                <div class="post-detail">
                    <h1 class="post-detail-title">${this.escapeHtml(post.title)}</h1>
                    <div class="post-detail-meta">
                        By ${this.escapeHtml(post.author)} on ${this.formatDate(post.createdDate)}
                        ${post.updatedDate ? `<br>Last updated: ${this.formatDate(post.updatedDate)}` : ''}
                    </div>
                    <div class="post-detail-content">${this.escapeHtml(post.content).replace(/\n/g, '<br>')}</div>
                </div>
            `;
            
            document.getElementById('post-detail').innerHTML = detailHtml;
            this.showView('detail');
        } catch (error) {
            this.showError('Failed to load post: ' + error.message);
        }
    }

    async handleFormSubmit(e) {
        e.preventDefault();
        
        const formData = {
            title: document.getElementById('title').value,
            author: document.getElementById('author').value,
            summary: document.getElementById('summary').value,
            content: document.getElementById('content').value,
            isPublished: document.getElementById('is-published').checked
        };

        const postId = document.getElementById('post-id').value;
        const isEdit = postId !== '';

        try {
            const url = isEdit ? `/api/posts/${postId}` : '/api/posts';
            const method = isEdit ? 'PUT' : 'POST';
            
            const response = await fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });

            if (response.ok) {
                await this.loadPosts();
                this.showPostsList();
                this.showSuccess(`Post ${isEdit ? 'updated' : 'created'} successfully!`);
            } else {
                throw new Error(`Failed to ${isEdit ? 'update' : 'create'} post`);
            }
        } catch (error) {
            this.showError(`Failed to save post: ${error.message}`);
        }
    }

    resetForm() {
        document.getElementById('post-form').reset();
        document.getElementById('post-id').value = '';
        document.getElementById('is-published').checked = true;
    }

    showView(view) {
        // Hide all views
        document.getElementById('posts-container').classList.add('hidden');
        document.getElementById('post-form-container').classList.add('hidden');
        document.getElementById('post-detail-container').classList.add('hidden');

        // Show selected view
        switch (view) {
            case 'list':
                document.getElementById('posts-container').classList.remove('hidden');
                break;
            case 'form':
                document.getElementById('post-form-container').classList.remove('hidden');
                break;
            case 'detail':
                document.getElementById('post-detail-container').classList.remove('hidden');
                break;
        }
        
        this.currentView = view;
    }

    showPostsList() {
        this.showView('list');
    }

    showLoading() {
        document.getElementById('posts-list').innerHTML = '<p class="loading">Loading posts...</p>';
    }

    showError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error';
        errorDiv.textContent = message;
        
        // Remove existing error messages
        const existingErrors = document.querySelectorAll('.error');
        existingErrors.forEach(err => err.remove());
        
        // Insert at the top of the container
        const container = document.querySelector('.container main');
        container.insertBefore(errorDiv, container.firstChild);
        
        // Auto-remove after 5 seconds
        setTimeout(() => errorDiv.remove(), 5000);
    }

    showSuccess(message) {
        const successDiv = document.createElement('div');
        successDiv.className = 'error'; // Reusing error styles but with success colors
        successDiv.style.backgroundColor = '#d4edda';
        successDiv.style.color = '#155724';
        successDiv.style.borderColor = '#c3e6cb';
        successDiv.textContent = message;
        
        // Remove existing messages
        const existingMessages = document.querySelectorAll('.error');
        existingMessages.forEach(msg => msg.remove());
        
        // Insert at the top of the container
        const container = document.querySelector('.container main');
        container.insertBefore(successDiv, container.firstChild);
        
        // Auto-remove after 3 seconds
        setTimeout(() => successDiv.remove(), 3000);
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the application when the page loads
let blogApp;
document.addEventListener('DOMContentLoaded', () => {
    blogApp = new BlogApp();
});

import http from './http'

export const login = (data) => {
  return http.post('/api/login', data)
}

export const register = (data) => {
  return http.post('/api/register', data)
}

export const resetPassword = (data) => {
  return http.post('/api/reset-password', data)
}

export const me = () => {
  return http.get('/api/me')
}

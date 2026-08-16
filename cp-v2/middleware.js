import { NextResponse } from 'next/server';
export const config={matcher:['/((?!api/auth|login.html|_next|favicon.ico).*)']};
export default async function middleware(req){
  if(process.env.CP_AUTH_ENABLED!=='true') return NextResponse.next();
  const token=req.cookies.get('cp_session')?.value;
  if(!token) return NextResponse.redirect(new URL('/login.html',req.url));
  return NextResponse.next();
}

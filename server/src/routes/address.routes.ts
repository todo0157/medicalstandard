import { Router } from 'express';
import { z } from 'zod';
import { authenticate, AuthenticatedRequest } from '../middleware/auth.middleware';
import { env } from '../config';
import postalCodeService from '../services/postal-code.service';

const router = Router();

const searchSchema = z.object({
  query: z.string().min(1).max(200),
});

// 네이버 지도 API를 통한 주소 검색 (Geocoding)
router.get('/search', authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const { query } = searchSchema.parse(req.query);
    
    // 우편번호 감지 (5자리 숫자)
    const isPostalCode = /^\d{5}$/.test(query.trim());
    
    if (env.NODE_ENV === 'development') {
      console.log('[Address Search] Query:', query);
      console.log('[Address Search] Is postal code:', isPostalCode);
    }
    
    // 우편번호 검색인 경우 우편번호 DB에서 검색
    if (isPostalCode) {
      try {
        const postalResults = await postalCodeService.searchByPostalCode(query.trim());
        
        if (postalResults.length === 0) {
          return res.status(404).json({
            message: '해당 우편번호로 주소를 찾을 수 없습니다.',
            details: '우편번호를 확인해주세요.',
            data: {
              addresses: [],
              total: 0,
            },
          });
        }

        // 네이버 지도 API 키 확인 (좌표 가져오기용)
        const clientId = env.NAVER_MAP_CLIENT_ID;
        const clientSecret = env.NAVER_MAP_CLIENT_SECRET;
        
        // Address 형식으로 변환
        // 사용자 제안 방식: 우편번호 DB에서 주소 목록만 반환하고, 
        // 사용자가 선택한 주소를 네이버 지도 API로 검색하여 좌표 가져오기
        // 따라서 여기서는 좌표 없이 주소 정보만 반환 (최대 100개)
        const maxResults = 100;
        const addresses = postalResults.slice(0, maxResults).map((result) => {
          // roadAddress와 jibunAddress가 비어있지 않은지 확인
          const roadAddr = result.roadAddress || '';
          const jibunAddr = result.jibunAddress || '';
          
          if (!roadAddr && !jibunAddr) {
            console.warn('[PostalCodeService] Empty address found:', result);
            return null;
          }
          
          return {
            roadAddress: roadAddr,
            jibunAddress: jibunAddr,
            englishAddress: '',
            x: 0.0, // double 타입으로 명시
            y: 0.0, // double 타입으로 명시
            distance: 0.0,
            addressElements: [] as any[],
          };
        }).filter((addr): addr is NonNullable<typeof addr> => addr !== null);

        if (env.NODE_ENV === 'development') {
          console.log('[PostalCodeService] Found', addresses.length, 'addresses for postal code', query);
        }

        return res.json({
          data: {
            addresses,
            total: addresses.length,
          },
        });
      } catch (error) {
        console.error('[PostalCodeService] Error:', error);
        return res.status(500).json({
          message: '우편번호 검색 중 오류가 발생했습니다.',
          details: error instanceof Error ? error.message : '알 수 없는 오류',
        });
      }
    }
    
    // 일반 주소 검색인 경우 네이버 지도 API 사용
    // 네이버 지도 API 키 확인
    const clientId = env.NAVER_MAP_CLIENT_ID;
    const clientSecret = env.NAVER_MAP_CLIENT_SECRET;
    
    if (!clientId || !clientSecret) {
      console.error('[Naver Map API] Missing credentials:', {
        hasClientId: !!clientId,
        hasClientSecret: !!clientSecret,
      });
      return res.status(500).json({
        message: '네이버 지도 API가 설정되지 않았습니다.',
        details: '서버 환경 변수 NAVER_MAP_CLIENT_ID와 NAVER_MAP_CLIENT_SECRET을 확인해주세요.',
      });
    }

    // API 키 형식 검증
    if (clientId.trim().length === 0 || clientSecret.trim().length === 0) {
      console.error('[Naver Map API] Empty credentials');
      return res.status(500).json({
        message: '네이버 지도 API 키가 비어있습니다.',
        details: '서버 환경 변수를 확인해주세요.',
      });
    }

    // 네이버 지도 Geocoding API 호출
    // 공식 문서: https://api.ncloud-docs.com/docs/ko/application-maps-geocoding
    const naverApiUrl = 'https://maps.apigw.ntruss.com/map-geocode/v2/geocode';
    
    // 우편번호인 경우 그대로 전달 (네이버 지도 API가 우편번호를 지원하는지 확인)
    // 우편번호는 5자리 숫자이므로 그대로 전달해도 작동할 수 있음
    const searchQuery = query.trim();
    const requestUrl = `${naverApiUrl}?query=${encodeURIComponent(searchQuery)}`;
    
    // API 키 값 검증 및 로깅
    const trimmedClientId = clientId.trim();
    const trimmedClientSecret = clientSecret.trim();
    
    if (env.NODE_ENV === 'development') {
      console.log('[Naver Map API] Request URL:', requestUrl);
      console.log('[Naver Map API] Client ID (first 4):', trimmedClientId.substring(0, 4));
      console.log('[Naver Map API] Client ID length:', trimmedClientId.length);
      console.log('[Naver Map API] Client Secret length:', trimmedClientSecret.length);
      console.log('[Naver Map API] Client ID has spaces:', clientId !== trimmedClientId);
      console.log('[Naver Map API] Client Secret has spaces:', clientSecret !== trimmedClientSecret);
    }
    
    // API 키 형식 검증 (네이버 API 키는 보통 특정 형식을 가짐)
    if (trimmedClientId.length < 5 || trimmedClientSecret.length < 20) {
      console.error('[Naver Map API] Invalid key format:', {
        clientIdLength: trimmedClientId.length,
        clientSecretLength: trimmedClientSecret.length,
      });
      return res.status(500).json({
        message: '네이버 지도 API 키 형식이 올바르지 않습니다.',
        details: 'Client ID와 Client Secret의 길이를 확인해주세요.',
      });
    }
    
    // 네이버 API 호출 시 헤더 설정 (공식 문서 기준)
    // Accept 헤더는 필수입니다 (공식 문서: Required)
    const headers: Record<string, string> = {
      'Accept': 'application/json',
      'x-ncp-apigw-api-key-id': trimmedClientId,
      'x-ncp-apigw-api-key': trimmedClientSecret,
    };
    
    if (env.NODE_ENV === 'development') {
      console.log('[Naver Map API] Request headers:', {
        'Accept': 'application/json',
        'x-ncp-apigw-api-key-id': trimmedClientId.substring(0, 4) + '...',
        'x-ncp-apigw-api-key': trimmedClientSecret.substring(0, 4) + '...',
      });
    }
    
    const response = await fetch(requestUrl, {
      method: 'GET',
      headers: headers,
    });

    if (!response.ok) {
      const errorText = await response.text();
      const responseHeaders = Object.fromEntries(response.headers.entries());
      
      console.error('[Naver Map API] Error:', response.status, errorText);
      console.error('[Naver Map API] Response headers:', responseHeaders);
      
      // 네이버 API의 401 에러는 500으로 변환하여 인증 실패로 오인되지 않도록 함
      // (네이버 API 구독 문제는 인증 문제가 아님)
      const statusCode = response.status === 401 ? 500 : response.status;
      
      let errorMessage = '네이버 지도 API 오류가 발생했습니다.';
      let troubleshooting = '';
      
      if (response.status === 401) {
        try {
          const errorData = JSON.parse(errorText);
          const errorCode = errorData?.error?.errorCode;
          const errorMsg = errorData?.error?.message;
          const errorDetails = errorData?.error?.details;
          
          console.error('[Naver Map API] Error details:', {
            errorCode,
            message: errorMsg,
            details: errorDetails,
            fullError: errorData,
          });
          
          if (errorMsg === 'Permission Denied' || errorCode === '210') {
            errorMessage = '네이버 지도 API 접근 권한이 없습니다.';
            troubleshooting = `
다음 사항을 순서대로 확인해주세요:

1. **서버 재시작 확인**
   - API 키를 변경했다면 서버를 반드시 재시작해야 합니다
   - 서버 디렉토리에서: npm start

2. **Application 인증 정보 확인**
   - 네이버 클라우드 플랫폼 콘솔 → Maps → Application → "hanbang" 클릭
   - "인증 정보" 탭에서 Client ID와 Client Secret 확인
   - 서버의 .env 파일과 정확히 일치하는지 확인 (공백, 따옴표 없이)

3. **API 등록 확인**
   - "API 설정" 또는 "서비스 등록" 탭에서 "Geocoding" API가 등록되어 있는지 확인
   - Application에 Geocoding API가 활성화되어 있는지 확인

4. **API 키 형식 확인**
   - Client ID: 보통 10자리 문자열
   - Client Secret: 보통 40자리 문자열
   - 앞뒤 공백이 없어야 함
   - 따옴표 없이 입력

5. **Application 일치 확인**
   - 사용 중인 API 키가 "hanbang" Application에 속해 있는지 확인
   - 다른 Application의 키를 사용하고 있지 않은지 확인

6. **Web Service URL 확인**
   - Application 설정에서 Web Service URL이 올바르게 설정되어 있는지 확인
   - 서버 도메인 또는 localhost가 허용되어 있는지 확인
            `.trim();
          } else {
            errorMessage = '네이버 지도 API 키가 유효하지 않습니다.';
            troubleshooting = `
다음 사항을 확인해주세요:
1. 네이버 클라우드 플랫폼 콘솔에서 Application의 인증 정보 확인
2. API 키가 올바른 Application에 속해 있는지 확인
3. API 키에 공백이나 특수 문자가 포함되지 않았는지 확인
4. 서버를 재시작했는지 확인
            `.trim();
          }
        } catch (parseError) {
          console.error('[Naver Map API] Failed to parse error response:', parseError);
          console.error('[Naver Map API] Raw error text:', errorText);
          errorMessage = '네이버 지도 API 응답을 파싱할 수 없습니다.';
          troubleshooting = `
다음 사항을 확인해주세요:
1. 네이버 클라우드 플랫폼 콘솔에서 Application의 인증 정보 확인
2. 서버를 재시작했는지 확인
3. 네트워크 연결 상태 확인
            `.trim();
        }
      } else if (response.status === 403) {
        errorMessage = '네이버 지도 API 접근이 거부되었습니다.';
        troubleshooting = 'Application의 권한 설정을 확인해주세요.';
      } else if (response.status >= 500) {
        errorMessage = '네이버 지도 API 서버 오류가 발생했습니다.';
        troubleshooting = '잠시 후 다시 시도해주세요.';
      }
      
      return res.status(statusCode).json({
        message: '주소 검색에 실패했습니다.',
        details: errorMessage,
        troubleshooting: troubleshooting || undefined,
        errorCode: response.status,
      });
    }

    const data = await response.json();
    
    // 네이버 API 응답 형식 확인 및 로깅 (개발 환경에서만)
    if (env.NODE_ENV === 'development') {
      console.log('[Naver Map API] Response status:', data.status);
      console.log('[Naver Map API] Response meta:', data.meta);
      console.log('[Naver Map API] Addresses count:', data.addresses?.length || 0);
      console.log('[Naver Map API] Error message:', data.errorMessage);
    }
    
    // 공식 문서 기준 응답 형식: { status: "OK" | "INVALID_REQUEST" | "SYSTEM_ERROR", meta: {...}, addresses: [...], errorMessage: "" }
    // status가 "OK"가 아니면 에러
    if (data.status !== 'OK') {
      console.error('[Naver Map API] Status error:', {
        status: data.status,
        errorMessage: data.errorMessage,
        fullResponse: data,
        isPostalCode,
      });
      
      // 우편번호 검색인 경우 더 구체적인 에러 메시지 제공
      if (isPostalCode) {
        return res.status(404).json({
          message: '우편번호로 주소를 찾을 수 없습니다.',
          details: data.errorMessage || `네이버 지도 API가 해당 우편번호를 찾지 못했습니다: ${data.status}`,
          suggestion: '우편번호 대신 도로명, 지번, 건물명으로 검색해보세요.',
        });
      }
      
      return res.status(500).json({
        message: '주소 검색에 실패했습니다.',
        details: data.errorMessage || `네이버 지도 API 오류: ${data.status}`,
      });
    }
    
    // 네이버 API 응답을 앱 형식으로 변환
    const addresses = (data.addresses || []).map((addr: any) => ({
      roadAddress: addr.roadAddress || '',
      jibunAddress: addr.jibunAddress || '',
      englishAddress: addr.englishAddress || '',
      addressElements: addr.addressElements || [],
      x: parseFloat(addr.x || '0'), // 경도
      y: parseFloat(addr.y || '0'), // 위도
      distance: addr.distance || 0,
    }));

    // 우편번호 검색인데 결과가 없는 경우
    if (isPostalCode && addresses.length === 0) {
      if (env.NODE_ENV === 'development') {
        console.log('[Address Search] Postal code search returned no results:', searchQuery);
      }
      return res.status(404).json({
        message: '해당 우편번호로 주소를 찾을 수 없습니다.',
        details: '네이버 지도 API가 해당 우편번호를 지원하지 않을 수 있습니다.',
        suggestion: '도로명, 지번, 건물명으로 검색해보세요.',
      });
    }

    if (env.NODE_ENV === 'development') {
      console.log('[Address Search] Results count:', addresses.length);
      if (isPostalCode) {
        console.log('[Address Search] Postal code search successful');
      }
    }

    return res.json({
      data: {
        addresses,
        total: addresses.length,
      },
    });
  } catch (error) {
    console.error('[Address Search] Unexpected error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: '입력값이 올바르지 않습니다.',
        issues: error.flatten().fieldErrors,
      });
    }
    if (error instanceof Error) {
      return res.status(500).json({
        message: '주소 검색 중 오류가 발생했습니다.',
        details: env.NODE_ENV === 'development' ? error.message : undefined,
      });
    }
    return next(error);
  }
});

// 역지오코딩 (좌표 → 주소)
router.get('/reverse', authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const lat = parseFloat(req.query.lat as string);
    const lng = parseFloat(req.query.lng as string);
    
    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({
        message: '위도와 경도가 올바르지 않습니다.',
      });
    }

    const clientId = env.NAVER_MAP_CLIENT_ID;
    const clientSecret = env.NAVER_MAP_CLIENT_SECRET;
    
    if (!clientId || !clientSecret) {
      console.error('[Naver Map API] Missing credentials for reverse geocoding');
      return res.status(500).json({
        message: '네이버 지도 API가 설정되지 않았습니다.',
        details: '서버 환경 변수 NAVER_MAP_CLIENT_ID와 NAVER_MAP_CLIENT_SECRET을 확인해주세요.',
      });
    }

    // API 키 형식 검증
    if (clientId.trim().length === 0 || clientSecret.trim().length === 0) {
      console.error('[Naver Map API] Empty credentials for reverse geocoding');
      return res.status(500).json({
        message: '네이버 지도 API 키가 비어있습니다.',
        details: '서버 환경 변수를 확인해주세요.',
      });
    }

    // 네이버 지도 Reverse Geocoding API 호출
    // 공식 문서 기준 엔드포인트 사용
    const naverApiUrl = 'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc';
    const requestUrl = `${naverApiUrl}?coords=${lng},${lat}&output=json`;
    
    if (env.NODE_ENV === 'development') {
      console.log('[Naver Map API] Reverse geocoding request URL:', requestUrl);
    }
    
    const response = await fetch(requestUrl, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'x-ncp-apigw-api-key-id': clientId.trim(),
        'x-ncp-apigw-api-key': clientSecret.trim(),
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('[Naver Map API] Reverse geocoding error:', response.status, errorText);
      
      // 네이버 API의 401 에러는 500으로 변환하여 인증 실패로 오인되지 않도록 함
      const statusCode = response.status === 401 ? 500 : response.status;
      
      let errorMessage = '네이버 지도 API 오류가 발생했습니다.';
      let troubleshooting = '';
      
      if (response.status === 401) {
        try {
          const errorData = JSON.parse(errorText);
          const errorCode = errorData?.error?.errorCode;
          const errorMsg = errorData?.error?.message;
          
          console.error('[Naver Map API] Reverse geocoding error details:', {
            errorCode,
            message: errorMsg,
            details: errorData?.error?.details,
          });
          
          if (errorMsg === 'Permission Denied' || errorCode === '210') {
            errorMessage = '네이버 지도 API 접근 권한이 없습니다.';
            troubleshooting = `
다음 사항을 확인해주세요:
1. 네이버 클라우드 플랫폼 콘솔 → Maps → Application → "hanbang" 클릭
2. "API 설정" 또는 "서비스 등록" 탭에서 "Reverse Geocoding" API가 등록되어 있는지 확인
3. Application의 "인증 정보"에서 Client ID와 Client Secret이 올바른지 확인
4. 서버의 .env 파일에 NAVER_MAP_CLIENT_ID와 NAVER_MAP_CLIENT_SECRET이 올바르게 설정되어 있는지 확인
5. Web Service URL이 올바르게 설정되어 있는지 확인
            `.trim();
          } else {
            errorMessage = '네이버 지도 API 키가 유효하지 않습니다.';
            troubleshooting = '네이버 클라우드 플랫폼 콘솔에서 Application의 인증 정보를 확인해주세요.';
          }
        } catch (parseError) {
          console.error('[Naver Map API] Failed to parse error response:', parseError);
          errorMessage = '네이버 지도 API 키가 유효하지 않습니다.';
          troubleshooting = '네이버 클라우드 플랫폼 콘솔에서 Application의 인증 정보를 확인해주세요.';
        }
      }
      
      return res.status(statusCode).json({
        message: '주소 변환에 실패했습니다.',
        details: errorMessage,
        troubleshooting: troubleshooting || undefined,
      });
    }

    const data = await response.json();
    
    // Reverse Geocoding API 응답 형식 확인 및 로깅 (개발 환경에서만)
    if (env.NODE_ENV === 'development') {
      console.log('[Naver Map API] Reverse geocoding response:', {
        status: data.status,
        resultsCount: data.results?.length || 0,
        fullResponse: JSON.stringify(data, null, 2),
      });
    }
    
    // Reverse Geocoding API 응답 형식 확인
    // 응답 형식은 { status: { code: 0, name: "OK", message: "" }, results: [...] } 또는
    // { status: "OK", results: [...] } 형식일 수 있음
    const statusCode = typeof data.status === 'object' ? data.status?.code : null;
    const statusString = typeof data.status === 'string' ? data.status : data.status?.name;
    
    if ((statusCode !== null && statusCode !== 0) || (statusString && statusString !== 'OK')) {
      console.error('[Naver Map API] Reverse geocoding status error:', {
        statusCode,
        statusString,
        fullResponse: data,
      });
      return res.status(500).json({
        message: '주소 변환에 실패했습니다.',
        details: typeof data.status === 'object' 
          ? data.status?.message || '네이버 지도 API 오류가 발생했습니다.'
          : `네이버 지도 API 오류: ${statusString}`,
      });
    }
    
    if (!data.results || data.results.length === 0) {
      return res.status(404).json({
        message: '해당 좌표의 주소를 찾을 수 없습니다.',
      });
    }

    const result = data.results[0];
    const address = {
      roadAddress: result.region?.area1?.name + ' ' + 
                   result.region?.area2?.name + ' ' + 
                   result.region?.area3?.name + ' ' + 
                   (result.region?.area4?.name || ''),
      jibunAddress: result.region?.area1?.name + ' ' + 
                    result.region?.area2?.name + ' ' + 
                    result.region?.area3?.name + ' ' + 
                    (result.region?.area4?.name || ''),
      x: lng,
      y: lat,
    };

    return res.json({ data: address });
  } catch (error) {
    return next(error);
  }
});

// 주소 선택 시 좌표 가져오기 (우편번호 검색 결과 선택 후 사용)
router.post('/geocode', authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const { roadAddress, jibunAddress } = req.body;
    
    if (!roadAddress && !jibunAddress) {
      return res.status(400).json({
        message: '도로명 주소 또는 지번 주소가 필요합니다.',
      });
    }

    const clientId = env.NAVER_MAP_CLIENT_ID;
    const clientSecret = env.NAVER_MAP_CLIENT_SECRET;
    
    if (!clientId || !clientSecret) {
      return res.status(500).json({
        message: '네이버 지도 API가 설정되지 않았습니다.',
      });
    }

    // 우선 도로명 주소로 검색, 없으면 지번 주소로 검색
    const searchQuery = roadAddress || jibunAddress;
    const naverApiUrl = 'https://maps.apigw.ntruss.com/map-geocode/v2/geocode';
    const requestUrl = `${naverApiUrl}?query=${encodeURIComponent(searchQuery)}`;

    const response = await fetch(requestUrl, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'x-ncp-apigw-api-key-id': clientId.trim(),
        'x-ncp-apigw-api-key': clientSecret.trim(),
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('[Naver Map API] Geocode error:', response.status, errorText);
      return res.status(500).json({
        message: '주소 좌표 변환에 실패했습니다.',
        details: '네이버 지도 API 오류가 발생했습니다.',
      });
    }

    const data = await response.json();

    if (data.status !== 'OK' || !data.addresses || data.addresses.length === 0) {
      return res.status(404).json({
        message: '해당 주소의 좌표를 찾을 수 없습니다.',
        details: data.errorMessage || '주소를 확인해주세요.',
      });
    }

    const address = data.addresses[0];
    return res.json({
      data: {
        roadAddress: address.roadAddress || roadAddress,
        jibunAddress: address.jibunAddress || jibunAddress,
        x: parseFloat(address.x || '0'),
        y: parseFloat(address.y || '0'),
      },
    });
  } catch (error) {
    console.error('[Address Geocode] Error:', error);
    return next(error);
  }
});

export default router;


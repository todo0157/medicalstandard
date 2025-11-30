"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
class PostalCodeService {
    constructor() {
        // search_number 폴더 경로 설정
        // 여러 경로 시도 (다양한 실행 환경 대응)
        // 1. __dirname 기반: dist/services/postal-code.service.js -> ../../.. -> 프로젝트 루트
        // 2. process.cwd() 기반: server 디렉토리에서 실행 시 -> .. -> 프로젝트 루트
        // 3. process.cwd() 기반: 프로젝트 루트에서 실행 시 -> 직접 접근
        this.cache = new Map();
        const possiblePaths = [];
        // __dirname 기반 경로 (컴파일된 파일 위치 기준)
        try {
            const projectRootFromDirname = path.resolve(__dirname, '..', '..', '..');
            possiblePaths.push(path.join(projectRootFromDirname, 'search_number'));
        }
        catch (e) {
            // __dirname이 없는 경우 무시
        }
        // process.cwd() 기반 경로들
        const cwd = process.cwd();
        possiblePaths.push(path.join(cwd, '..', 'search_number'), // server 디렉토리에서 실행 시
        path.join(cwd, 'search_number'));
        // 절대 경로로도 시도 (프로젝트 루트가 C:\Users\thf56\Documents\medicalstandard인 경우)
        if (cwd.includes('medicalstandard')) {
            const projectRootMatch = cwd.match(/^(.*medicalstandard)/);
            if (projectRootMatch) {
                possiblePaths.push(path.join(projectRootMatch[1], 'search_number'));
            }
        }
        // 경로 찾기
        let found = false;
        for (const possiblePath of possiblePaths) {
            const normalizedPath = path.normalize(possiblePath);
            if (fs.existsSync(normalizedPath)) {
                this.dataDir = normalizedPath;
                console.log(`[PostalCodeService] ✓ Data directory found: ${this.dataDir}`);
                found = true;
                break;
            }
        }
        if (!found) {
            // 기본값 설정 (에러는 나중에 발생)
            this.dataDir = possiblePaths[0] || path.join(process.cwd(), '..', 'search_number');
            console.error(`[PostalCodeService] ✗ Data directory not found. Tried paths:`);
            possiblePaths.forEach((p, i) => {
                const normalized = path.normalize(p);
                const exists = fs.existsSync(normalized);
                console.error(`  ${i + 1}. ${normalized} ${exists ? '✓' : '✗'}`);
            });
            console.error(`[PostalCodeService] Current working directory: ${process.cwd()}`);
            console.error(`[PostalCodeService] __dirname: ${__dirname}`);
        }
    }
    /**
     * TSV 파일에서 한 줄을 파싱하여 PostalCodeRecord로 변환
     */
    parseLine(line) {
        const parts = line.split('|');
        if (parts.length < 26) {
            return null;
        }
        return {
            postalCode: parts[0]?.trim() || '',
            sido: parts[1]?.trim() || '',
            sidoEnglish: parts[2]?.trim() || '',
            sigungu: parts[3]?.trim() || '',
            sigunguEnglish: parts[4]?.trim() || '',
            eupmyeon: parts[5]?.trim() || '',
            eupmyeonEnglish: parts[6]?.trim() || '',
            roadNameCode: parts[7]?.trim() || '',
            roadName: parts[8]?.trim() || '',
            roadNameEnglish: parts[9]?.trim() || '',
            buildingMainNumber: parts[11]?.trim() || '',
            buildingSubNumber: parts[12]?.trim() || '',
            buildingName: parts[15]?.trim() || '',
            beopjeongdong: parts[17]?.trim() || '',
            haengjeongdong: parts[19]?.trim() || '',
            jibunMain: parts[21]?.trim() || '',
            jibunSub: parts[23]?.trim() || '',
        };
    }
    /**
     * PostalCodeRecord를 AddressResult로 변환
     */
    recordToAddress(record) {
        // 도로명 주소 구성
        let roadAddress = `${record.sido} ${record.sigungu}`;
        if (record.eupmyeon) {
            roadAddress += ` ${record.eupmyeon}`;
        }
        if (record.roadName) {
            roadAddress += ` ${record.roadName}`;
            if (record.buildingMainNumber) {
                roadAddress += ` ${record.buildingMainNumber}`;
                if (record.buildingSubNumber && record.buildingSubNumber !== '0') {
                    roadAddress += `-${record.buildingSubNumber}`;
                }
            }
        }
        if (record.buildingName) {
            roadAddress += ` (${record.buildingName})`;
        }
        // 지번 주소 구성
        let jibunAddress = `${record.sido} ${record.sigungu}`;
        if (record.eupmyeon) {
            jibunAddress += ` ${record.eupmyeon}`;
        }
        if (record.beopjeongdong) {
            jibunAddress += ` ${record.beopjeongdong}`;
        }
        if (record.jibunMain) {
            jibunAddress += ` ${record.jibunMain}`;
            if (record.jibunSub && record.jibunSub !== '0') {
                jibunAddress += `-${record.jibunSub}`;
            }
        }
        return {
            roadAddress: roadAddress.trim(),
            jibunAddress: jibunAddress.trim(),
            postalCode: record.postalCode,
            sido: record.sido,
            sigungu: record.sigungu,
            eupmyeon: record.eupmyeon || undefined,
            roadName: record.roadName || undefined,
            buildingNumber: record.buildingMainNumber || undefined,
            buildingName: record.buildingName || undefined,
            beopjeongdong: record.beopjeongdong || undefined,
            haengjeongdong: record.haengjeongdong || undefined,
        };
    }
    /**
     * 특정 파일에서 우편번호 검색
     */
    searchInFile(filePath, postalCode) {
        const results = [];
        const seen = new Set();
        try {
            // 파일이 존재하는지 확인
            if (!fs.existsSync(filePath)) {
                console.warn(`[PostalCodeService] File not found: ${filePath}`);
                return results;
            }
            // 파일 크기가 너무 크면 스트림으로 읽기 (메모리 효율)
            const stats = fs.statSync(filePath);
            const fileSizeInMB = stats.size / (1024 * 1024);
            if (fileSizeInMB > 50) {
                // 큰 파일은 스트림으로 읽기
                return this.searchInFileStream(filePath, postalCode);
            }
            const fileContent = fs.readFileSync(filePath, 'utf-8');
            const lines = fileContent.split('\n');
            // 첫 번째 줄은 헤더이므로 건너뛰기
            for (let i = 1; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line)
                    continue;
                const record = this.parseLine(line);
                if (!record || record.postalCode !== postalCode) {
                    continue;
                }
                const address = this.recordToAddress(record);
                // 중복 제거를 위한 키 생성
                const key = `${address.roadAddress}|${address.jibunAddress}`;
                if (!seen.has(key)) {
                    seen.add(key);
                    results.push(address);
                }
            }
        }
        catch (error) {
            console.error(`[PostalCodeService] Error reading file ${filePath}:`, error);
            if (error instanceof Error) {
                console.error(`[PostalCodeService] Error message: ${error.message}`);
            }
        }
        return results;
    }
    /**
     * 큰 파일을 스트림으로 읽어서 검색 (메모리 효율)
     */
    searchInFileStream(filePath, postalCode) {
        const results = [];
        const seen = new Set();
        let isFirstLine = true;
        try {
            const fileContent = fs.readFileSync(filePath, 'utf-8');
            // 줄 단위로 처리
            const lines = fileContent.split('\n');
            for (const line of lines) {
                const trimmedLine = line.trim();
                if (!trimmedLine)
                    continue;
                // 첫 번째 줄은 헤더
                if (isFirstLine) {
                    isFirstLine = false;
                    continue;
                }
                const record = this.parseLine(trimmedLine);
                if (!record || record.postalCode !== postalCode) {
                    continue;
                }
                const address = this.recordToAddress(record);
                const key = `${address.roadAddress}|${address.jibunAddress}`;
                if (!seen.has(key)) {
                    seen.add(key);
                    results.push(address);
                }
            }
        }
        catch (error) {
            console.error(`[PostalCodeService] Error in stream search for ${filePath}:`, error);
        }
        return results;
    }
    /**
     * 우편번호로 주소 검색
     */
    async searchByPostalCode(postalCode) {
        // 우편번호 형식 검증 (5자리 숫자)
        if (!/^\d{5}$/.test(postalCode)) {
            throw new Error('우편번호는 5자리 숫자여야 합니다.');
        }
        // 캐시 확인
        if (this.cache.has(postalCode)) {
            console.log(`[PostalCodeService] Cache hit for postal code: ${postalCode}`);
            return this.cache.get(postalCode);
        }
        const results = [];
        try {
            // 데이터 디렉토리 확인
            if (!fs.existsSync(this.dataDir)) {
                console.error(`[PostalCodeService] Data directory does not exist: ${this.dataDir}`);
                throw new Error(`우편번호 데이터 디렉토리를 찾을 수 없습니다: ${this.dataDir}`);
            }
            // 모든 지역 파일 검색
            const files = fs.readdirSync(this.dataDir);
            const txtFiles = files.filter(f => f.endsWith('.txt') && !f.includes('설명'));
            console.log(`[PostalCodeService] Searching in ${txtFiles.length} files for postal code: ${postalCode}`);
            if (txtFiles.length === 0) {
                console.error(`[PostalCodeService] No .txt files found in ${this.dataDir}`);
                throw new Error('우편번호 데이터 파일을 찾을 수 없습니다.');
            }
            for (const file of txtFiles) {
                const filePath = path.join(this.dataDir, file);
                const fileResults = this.searchInFile(filePath, postalCode);
                if (fileResults.length > 0) {
                    console.log(`[PostalCodeService] Found ${fileResults.length} results in ${file}`);
                }
                results.push(...fileResults);
            }
            // 결과 정렬 (도로명 주소 기준)
            results.sort((a, b) => a.roadAddress.localeCompare(b.roadAddress));
            console.log(`[PostalCodeService] Total results for ${postalCode}: ${results.length}`);
            // 캐시에 저장 (최대 1000개까지만 캐시)
            if (this.cache.size < 1000) {
                this.cache.set(postalCode, results);
            }
            return results;
        }
        catch (error) {
            console.error('[PostalCodeService] Error searching postal code:', error);
            if (error instanceof Error) {
                throw error;
            }
            throw new Error('우편번호 검색 중 오류가 발생했습니다.');
        }
    }
    /**
     * 캐시 초기화
     */
    clearCache() {
        this.cache.clear();
    }
}
exports.default = new PostalCodeService();

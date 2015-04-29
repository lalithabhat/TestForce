/**
 * Controller class for PerfLog VF page
 */
public with sharing class PerfLogController {
    /**
     * Default contructor
     */
    public PerfLogController() {
        //Retreiving Visualforce pages
        List<ApexPage> avaliablePages = [Select Name From ApexPage Order By Name Asc];
        apexPages = new List<String>();
        for (ApexPage page : avaliablePages) {
            apexPages.add(page.Name);
        }
    }
    /**
     * List of ORG's available visualforce pages
     */
    public List<String> apexPages {get; set;}
    /**
     * Initiate logging. Creates TraceFlag to capture logs
     * @param  input action input objects. Contains VF page url and object id
     * @return       Initiate logging info.
     */
    @RemoteAction
    public static LoggingInfo startLogging(StartLoggingInput input) {
        Url u = new Url(input.url);

        LoggingInfo result = new LoggingInfo();
        result.fullPageUrl = input.url;
        result.vfPageName = u.getPath();
        ToolingAPI.TraceFlag flag = new ToolingAPI.TraceFlag();
        flag.apexCode = 'Info';
        flag.apexProfiling = 'Info';
        flag.callout = 'Info';
        flag.database = 'Info';
        flag.expirationDate = Datetime.now().addMinutes(2);
        flag.system_x = 'Info';
        flag.tracedEntityId = UserInfo.getUserId();
        flag.validation = 'Info';
        flag.visualforce = 'Info';
        flag.workflow = 'Info';
        ToolingAPI toolApi = new ToolingAPI();
        result.fromTimestamp = Datetime.now().getTime(); // Setting DateTime in GMT
        toolApi.createSObject(flag);
        return result;
    }
    /**
     * Gets Latest ApexLog Id for needed operation,user
     * @param  opName   operation name
     * @param  fromTime time filter. ApexLog with StartTime less than fromTime won't be returned
     * @param  userId   requester user id
     * @return          ApexLog ID
     */
    @TestVisible
    private static Id getApexLogId(String opName, Datetime fromTime, Id userId) {
        try {
            String likeQueryStr = '\'%' + opName + '%\'';
            Datetime startTime = fromTime;
            Id usrId = userId;
            ApexLog log = (ApexLog)(Database.query('Select Id From ApexLog Where Operation Like ' + likeQueryStr + ' AND StartTime >= :startTime AND LogUserId = :usrId')[0]);
            return log.Id;
        } catch (Exception e) {
            return null;
        }

    }
    /**
     * Gets ApexLog w/ body from Tooling API.
     * @param  id ApexLog Id
     * @return    ApexLog w/ body
     */
    @TestVisible
    private static ToolingAPI.ApexLog getApexLog(String id){
    	if(Test.isRunningTest()){
    		ToolingAPI.ApexLog log = new ToolingAPI.ApexLog();
    		log.durationMilliseconds = 350;
    		log.operation = '/apex/test';
    		log.body = PerfLogControllerTest.testLog;
    		return log;
    	}
    	return new ToolingAPI().retrieveApexLog(id);
    }
    /**
     * Returns log info for needed VF page
     * @param  info LoggingInfo object retreived from startLogging action
     * @return      Full LoggingInfo object
     */
    @RemoteAction
    public static LoggingInfo requestLogInfo(LoggingInfo info) {
        Id userId = UserInfo.getUserId();
        Datetime fromTime = Datetime.newInstance(info.fromTimestamp);
        Id logId = getApexLogId(String.escapeSingleQuotes(info.vfPageName),fromTime,(Id)UserInfo.getUserId());
        if(!Test.isRunningTest()&&logId==null)
        	throw new PerfLogException('Cannot find ApexLog record.');
        ToolingApi.ApexLog toolApexLog = getApexLog(logId);
        Map<String, String> params = null;
        String id = null;
        if (info.fullPageUrl != null) {
            Url u = new Url(info.fullPageUrl);
            params = getParams('id', u.getQuery());
            id = params.get('id');
            //Actually I don't know if I should delete id parameter from params.
        }
        createLog(toolApexLog.durationMilliseconds, toolApexLog.operation, id, params);
        info.durationInMillis = toolApexLog.durationMilliseconds;
        info.operations = parseLogFile(toolApexLog.body);
        info.debugLogBody = toolApexLog.body;
        return info;
    }
    /**
     * Creates Performance_Log__c object
     * @param gtime             Page generation time
     * @param path              VF page path
     * @param id                object id
     * @param Map<String,String> params other request parameters
     */
    private static void createLog(Integer gtime, String path, String id, Map<String, String> params) {
        Performance_Log__c pl = new Performance_Log__c();

        pl.page_name__c = path;
        pl.Page_Generation_Time__c = gtime;
        pl.requesting_user__c = UserInfo.getUserId();
        pl.record_id__c = id;
        insert pl;

        List<Performance_Log_Parameter__c> plps = new List<Performance_Log_Parameter__c>();
        if (params != null)
            for (String param : params.keySet()) {
                Performance_Log_Parameter__c plp = new Performance_Log_Parameter__c();
                plp.name__c = param;
                plp.value__c = params.get(param);
                plp.Performance_Log__c = pl.id;
                plps.add(plp);
            }
        if (plps.size() > 0)
            insert plps;

    }
    /**
     * Return Map with neded queryString parameters
     * @param  params QueryString parameters names separated with ','
     * @param  query  URL's query
     * @return        Key/Value collection of needed QueryString parameters
     */
    @TestVisible
    private static Map<String, String> getParams(String params, String query) {
        Map<String, String> paramMap = new Map<String, String>();

        if (!String.isBlank(params) && !String.isBlank(query)) {
            List<String> paramQuery = query.split('&');
            Set<String> includeParams = new Set<String>(params.split(','));
            System.debug(includeParams);
            System.debug(paramQuery);
            for (String param : paramQuery) {
                List<String> keyValue = param.split('=');
                if (includeParams.contains(keyValue[0])) {
                    paramMap.put(keyValue[0], keyValue[1]);
                }
            }
        }

        return paramMap;
    }


    /**
     * Parses ApexLog's body
     * @param  logBody ApexLog's body
     * @return         List of available log operations
     */
    @TestVisible
    private static List<LogOperation> parseLogFile(String logBody) {
        if (logBody == null || String.isBlank(logBody))
            return null;
        List<String> logLines = logBody.split('\n');
        //Used for determine if loop in needed part of ApexLog file
        Boolean isInMainBody = false;
        Long startTime = null;
        List<LogOperation> result = new List<LogOperation>();
        Integer currentLine = -1;
        for (String logLine : LogLines) {
            ++currentLine;
            if (logLine.contains('EXECUTION_STARTED')) {
                isInMainBody = true;
                startTime = getLogStringMilliseconds(logLine);
                continue;
            }
            //Skiping lines until Execution is starded of after execution is ended
            if (!isInMainBody) continue;
            if (logLine.contains('EXECUTION_FINISHED')) {
                isInMainBody = false;
                continue;
            }
            String operationType = '';
            List<String> parts = logLine.split('\\|');
            //Skip unneded line
            if (parts.size() < 2) continue;
            LogOperationType logType = getLogOperationType(parts[1]);
            //Skip unsupported operation
            if (logType == null) continue;
            if (parts[1].contains('STARTED') || parts[1].contains('BEGIN')) {
                //Start of operation
                LogOperation startedOperation = new LogOperation(getLogActionInfo(logLine), getLogStringMilliseconds(logLine) - startTime, logType);
                startedOperation.startLineNumber = currentLine;
                result.add(startedOperation);
            } else if (parts[1].contains('FINISHED') || parts[1].contains('END')) {
                //End of operation
                LogOperation endedOperation = getLastOfType(result, logType);
                endedOperation.endLineNumber = currentLine;
                endedOperation.msEnd = getLogStringMilliseconds(logLine) - startTime;
                endedOperation.isEnded = true;
            }
        }
        return result;
    }
    /**
     * Returns last item from list with provided type
     * @param  operations List of operations to search in
     * @param  logType    Needed log type
     * @return            LogOperation object or NULL if element wasn't found
     */
    private static LogOperation getLastOfType(List<LogOperation> operations, LogOperationType logType) {
        for (Integer i = operations.size() - 1; i >= 0; --i) {
            if (!operations[i].isEnded && operations[i].operationType == logType)
                return operations[i];
        }
        return null;
    }
    /**
     * Returns milliseconds representation of ApexLog timestamp
     * @param  logLine ApexLog's Body's line
     * @return     Number of milliseconds
     */
    @TestVisible
    private static Long getLogStringMilliseconds(String logLine) {
        String timeStr = logLine.split('\\|')[0].split('\\s')[0];
        Long seconds = Integer.valueOf(timeStr.substring(0, 2)) * 3600 + Integer.valueOf(timeStr.substring(3, 5)) * 60 + Integer.valueOf(timeStr.substring(6, 8));

        return seconds * 1000 + Integer.valueOf(timeStr.substring(9, 12));
    }
    /**
     * Retrieves Log Operation info from log's line
     * @param  logLine ApexLog's Body's line
     * @return     Operation info from provided log line
     */
    @TestVisible
    private static String getLogActionInfo(String logLine) {
        List<String> strs = logLine.split('\\|');
        String result = '';
        for (Integer i = 2; i < strs.size(); ++i) {
            result += strs[i] + '|';
        }
        if (String.isBlank(result)) return result;
        return result.substring(0, result.length() - 1);
    }
    /**
     * Return LogOperationType enum value for provided log line
     * @param  logLine ApexLog's Body's line
     * @return         LogOperationType or NULL if operation is unknown
     */
    @TestVisible
    private static LogOperationType getLogOperationType(String logLine) {
        if (logLine.contains('CODE_UNIT_STARTED') || logLine.contains('CODE_UNIT_FINISHED')) {
            return LogOperationType.CodeUnit;
        }
        if (logLine.contains('SOQL_EXECUTE_BEGIN') || logLine.contains('SOQL_EXECUTE_END')) {
            return LogOperationType.Soql;
        }
        if (logLine.contains('SOSL_EXECUTE_BEGIN') || logLine.contains('SOSL_EXECUTE_END')) {
            return LogOperationType.Sosl;
        }
        if (logLine.contains('VF_SERIALIZE_VIEWSTATE_BEGIN') || logLine.contains('VF_SERIALIZE_VIEWSTATE_END')) {
            return LogOperationType.VfSerializeViewState;
        }
        if (logLine.contains('VF_DESERIALIZE_VIEWSTATE_BEGIN') || logLine.contains('VF_DESERIALIZE_VIEWSTATE_END')) {
            return LogOperationType.VfDeserializeViewState;
        }
        if (logLine.contains('DML_BEGIN') || logLine.contains('DML_END')) {
            return LogOperationType.Dml;
        }
        if (logLine.contains('METHOD_ENTRY') || logLine.contains('METHOD_EXIT')) {
            return LogOperationType.Method;
        }
        if (logLine.contains('VF_EVALUATE_FORMULA_BEGIN') || logLine.contains('VF_EVALUATE_FORMULA_END')) {
            return LogOperationType.VFEvaluateFormula;
        }
        return null;
    }
    /**
     * Class representing log operation info
     */
    public class LogOperation {
        public String operation {get; set;}
        public Long msStart {get; set;}
        public Long msEnd {get; set;}
        public LogOperationType operationType {get; set;}
        public Boolean isEnded {get; set;}
        public Integer startLineNumber {get; set;}
        public Integer endLineNumber {get; set;}
        public LogOperation(String operation, Long msFromStart, LogOperationType operationType) {
            this.msStart = msFromStart;
            this.operation = operation;
            this.operationType = operationType;
            this.isEnded = false;
        }
    }
    /**
     * Input class for startLogging action
     */
    public class StartLoggingInput {
        public String url {get; set;}

        public StartLoggingInput() {}
    }
    /**
     * Class contains ApexLog infor for VF page profiling
     */
    public class LoggingInfo {
        public String fullPageUrl {get; set;}
        public Long fromTimestamp {get; set;}
        public String vfPageName {get; set;}
        public Long durationInMillis {get; set;}
        public List<LogOperation> operations {get; set;}
        public String debugLogBody {get; set;}
        public LoggingInfo() {

        }
    }
    /**
     * Enum representing Log operation type. For full reference see https://www.salesforce.com/us/developer/docs/apexcode/Content/code_setting_debug_log_levels.htm
     */
    public enum LogOperationType {
        CodeUnit,
        Soql,
        Sosl,
        VfSerializeViewState,
        VfDeserializeViewState,
        VFEvaluateFormula,
        Dml,
        Method
    }

    public class PerfLogException extends Exception{}
}
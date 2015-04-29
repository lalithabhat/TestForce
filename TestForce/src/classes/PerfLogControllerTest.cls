@isTest
public class PerfLogControllerTest {
	
	@isTest static void propertiesTest() {
		PerfLogController controller = new PerfLogController();
		List<String> vfPagesNames = controller.apexPages;
		System.assertNotEquals(null,vfPagesNames);
	}
	@isTest static void classesCoverageTest(){
		PerfLogController.LogOperation op = new PerfLogController.LogOperation('operation', 0, PerfLogController.LogOperationType.CodeUnit);
		PerfLogController.StartLoggingInput input = new PerfLogController.StartLoggingInput();
		PerfLogController.LoggingInfo info = new PerfLogController.LoggingInfo();
	}
	@isTest static void parseLogFileTest(){
		List<PerfLogController.LogOperation> operations = PerfLogController.parseLogFile(testLog);
		System.assertEquals(5,operations.size(),'Some operations are missing.');
		System.assertEquals(115,operations[0].msEnd-operations[0].msStart);

		operations = PerfLogController.parseLogFile(testLogWithoutExecutionStart);
		System.assertEquals(0,operations.size());
	}

	@isTest static void getLogOperationTypeTest(){
		PerfLogController.LogOperationType opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|CODE_UNIT_STARTED|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.CodeUnit,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|SOQL_EXECUTE_BEGIN|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Soql,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|SOSL_EXECUTE_BEGIN|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Sosl,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_SERIALIZE_VIEWSTATE_BEGIN|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VfSerializeViewState,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_DESERIALIZE_VIEWSTATE_BEGIN|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VfDeserializeViewState,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|DML_BEGIN|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Dml,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|METHOD_ENTRY|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Method,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_EVALUATE_FORMULA_BEGIN|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VFEvaluateFormula,opType);

		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|CODE_UNIT_FINISHED|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.CodeUnit,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|SOQL_EXECUTE_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Soql,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|SOSL_EXECUTE_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Sosl,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_SERIALIZE_VIEWSTATE_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VfSerializeViewState,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_DESERIALIZE_VIEWSTATE_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VfDeserializeViewState,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|DML_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Dml,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|METHOD_EXIT|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.Method,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_EVALUATE_FORMULA_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VFEvaluateFormula,opType);
		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|VF_EVALUATE_FORMULA_END|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(PerfLogController.LogOperationType.VFEvaluateFormula,opType);

		opType = PerfLogController.getLogOperationType('18:24:35.091 (91367114)|FLOW_RULE_DETAIL|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals(null,opType);
		
	}

	@isTest static void getLogActionInfoTest(){
		String actionInfoString = PerfLogController.getLogActionInfo('18:24:35.091 (91367114)|CODE_UNIT_STARTED|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog');
		System.assertEquals('[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog',actionInfoString);
	}

	@isTest static void getLogStringMillisecondsTest(){
		Long msResult = PerfLogController.getLogStringMilliseconds('00:00:00.010 (91285294)|EXECUTION_STARTED');
		System.assertEquals(10,msResult);
	}

	@isTest static void getParamsTest(){
		Map<String, String> params = PerfLogController.getParams('id', 'https://somesite.com?someParam=asd&id=1');
		System.assert(params.containsKey('id'));
		System.assertEquals('1',params.get('id'));
	}
	@isTest static void startLoggingTest(){
		Test.setMock(HttpCalloutMock.class, new ToolingAPITest.ToolingAPIMock(saveResultResponse, 201));
		PerfLogController.StartLoggingInput input = new PerfLogController.StartLoggingInput();
		input.url = 'https://testsite.com/apex/vfpage?id=1';
		PerfLogController.LoggingInfo info = PerfLogController.startLogging(input);
		System.assertEquals(input.url,info.fullPageUrl);
		System.assertEquals('/apex/vfpage',info.vfPageName);
	}
	@isTest static void requestLogInfoTest(){
		Test.setMock(HttpCalloutMock.class, new ToolingAPITest.ToolingAPIMock(apexLogResponse, 200));
		PerfLogController.LoggingInfo info = new PerfLogController.LoggingInfo();
		info.fromTimestamp = Datetime.now().getTime();
		info.vfPageName = '/apex/vfpage';
		info.fullPageUrl = 'https://testsite.com/apex/vfpage?id=1';
		info = PerfLogController.requestLogInfo(info);
		System.assertEquals(350,info.durationInMillis);
	}
	public static final String testLog = '31.0 APEX_CODE,INFO;APEX_PROFILING,INFO;CALLOUT,INFO;DB,INFO;SYSTEM,INFO;VALIDATION,INFO;VISUALFORCE,INFO;WORKFLOW,INFO\n'
											+'18:24:35.091 (91285294)|EXECUTION_STARTED\n'
											+'18:24:35.091 (91367114)|CODE_UNIT_STARTED|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog\n'
											+'18:24:35.176 (176911302)|CODE_UNIT_STARTED|[EXTERNAL]|01pw0000001taD8|PerfLogController <init>\n'
											+'18:24:35.176 (176935344)|SYSTEM_MODE_ENTER|true\n'
											+'18:24:35.177 (177687957)|SYSTEM_MODE_ENTER|false\n'
											+'18:24:35.177 (177700161)|SYSTEM_MODE_EXIT|false\n'
											+'18:24:35.177 (177733498)|SYSTEM_MODE_ENTER|false\n'
											+'18:24:35.178 (178019497)|SOQL_EXECUTE_BEGIN|[10]|Aggregations:0|select Name from ApexPage order by Name\n'
											+'18:24:35.181 (181992947)|SOQL_EXECUTE_END|[10]|Rows:3\n'
											+'18:24:35.182 (182730444)|SYSTEM_MODE_EXIT|false\n'
											+'18:24:35.182 (182763003)|CODE_UNIT_FINISHED|PerfLogController <init>\n'
											+'18:24:35.182 (182826909)|CODE_UNIT_STARTED|[EXTERNAL]|01pw0000001taD8|PerfLogController get(apexPages)\n'
											+'18:24:35.182 (182842021)|SYSTEM_MODE_ENTER|true\n'
											+'18:24:35.182 (182858849)|CODE_UNIT_STARTED|[EXTERNAL]|01pw0000001taD8|apexPages\n'
											+'18:24:35.182 (182920186)|CODE_UNIT_FINISHED|apexPages\n'
											+'18:24:35.182 (182937338)|CODE_UNIT_FINISHED|PerfLogController get(apexPages)\n'
											+'18:24:35.332 (206168731)|CUMULATIVE_LIMIT_USAGE\n'
											+'18:24:35.332|LIMIT_USAGE_FOR_NS|(default)|\n'
											+'Number of SOQL queries: 1 out of 100\n'
											+'Number of query rows: 3 out of 50000\n'
											+'Number of SOSL queries: 0 out of 20\n'
											+'Number of DML statements: 0 out of 150\n'
											+'Number of DML rows: 0 out of 10000\n'
											+'Maximum CPU time: 0 out of 10000\n'
											+'Maximum heap size: 0 out of 6000000\n'
											+'Number of callouts: 0 out of 10\n'
											+'Number of Email Invocations: 0 out of 10\n'
											+'Number of future calls: 0 out of 10\n'
											+'Number of Mobile Apex push calls: 0 out of 10\n\n'
											+'18:24:35.332|CUMULATIVE_LIMIT_USAGE_END\n\n'
											+'18:24:35.206 (206227512)|CODE_UNIT_FINISHED|VF: /apex/PerfLog\n'
											+'18:24:35.208 (208440243)|EXECUTION_FINISHED\n';
	private static final String testLogWithoutExecutionStart = '31.0 APEX_CODE,INFO;APEX_PROFILING,INFO;CALLOUT,INFO;DB,INFO;SYSTEM,INFO;VALIDATION,INFO;VISUALFORCE,INFO;WORKFLOW,INFO\n'
											+'18:24:35.091 (91367114)|CODE_UNIT_STARTED|[EXTERNAL]|066w00000007Wbl|VF: /apex/PerfLog\n'
											+'18:24:35.176 (176911302)|CODE_UNIT_STARTED|[EXTERNAL]|01pw0000001taD8|PerfLogController <init>\n'
											+'18:24:35.176 (176935344)|SYSTEM_MODE_ENTER|true\n'
											+'18:24:35.177 (177687957)|SYSTEM_MODE_ENTER|false\n'
											+'18:24:35.177 (177700161)|SYSTEM_MODE_EXIT|false\n'
											+'18:24:35.177 (177733498)|SYSTEM_MODE_ENTER|false\n'
											+'18:24:35.178 (178019497)|SOQL_EXECUTE_BEGIN|[10]|Aggregations:0|select Name from ApexPage order by Name\n'
											+'18:24:35.181 (181992947)|SOQL_EXECUTE_END|[10]|Rows:3\n'
											+'18:24:35.182 (182730444)|SYSTEM_MODE_EXIT|false\n'
											+'18:24:35.182 (182763003)|CODE_UNIT_FINISHED|PerfLogController <init>\n'
											+'18:24:35.182 (182826909)|CODE_UNIT_STARTED|[EXTERNAL]|01pw0000001taD8|PerfLogController get(apexPages)\n'
											+'18:24:35.182 (182842021)|SYSTEM_MODE_ENTER|true\n'
											+'18:24:35.182 (182858849)|CODE_UNIT_STARTED|[EXTERNAL]|01pw0000001taD8|apexPages\n'
											+'18:24:35.182 (182920186)|CODE_UNIT_FINISHED|apexPages\n'
											+'18:24:35.182 (182937338)|CODE_UNIT_FINISHED|PerfLogController get(apexPages)\n'
											+'18:24:35.332 (206168731)|CUMULATIVE_LIMIT_USAGE\n'
											+'18:24:35.332|LIMIT_USAGE_FOR_NS|(default)|\n'
											+'Number of SOQL queries: 1 out of 100\n'
											+'Number of query rows: 3 out of 50000\n'
											+'Number of SOSL queries: 0 out of 20\n'
											+'Number of DML statements: 0 out of 150\n'
											+'Number of DML rows: 0 out of 10000\n'
											+'Maximum CPU time: 0 out of 10000\n'
											+'Maximum heap size: 0 out of 6000000\n'
											+'Number of callouts: 0 out of 10\n'
											+'Number of Email Invocations: 0 out of 10\n'
											+'Number of future calls: 0 out of 10\n'
											+'Number of Mobile Apex push calls: 0 out of 10\n\n'
											+'18:24:35.332|CUMULATIVE_LIMIT_USAGE_END\n\n'
											+'18:24:35.206 (206227512)|CODE_UNIT_FINISHED|VF: /apex/PerfLog\n'
											+'18:24:35.208 (208440243)|EXECUTION_FINISHED\n';

	private static final String saveResultResponse = '{"id":"1","success":true}';
	private static final String apexLogResponse = '{'+
		'"durationMilliseconds":350,'+
		'}';
}